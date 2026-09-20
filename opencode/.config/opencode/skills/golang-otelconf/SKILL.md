---
name: golang-otelconf
description: "OpenTelemetry declarative configuration in Go — parsing YAML/JSON configuration files following the OpenTelemetry Configuration schema, creating SDK providers from configuration, environment variable substitution, custom unmarshaling with validation, and multi-provider SDK setup. Use when implementing OpenTelemetry declarative configuration, parsing OpenTelemetry configuration files, setting up OpenTelemetry SDK from configuration, or working with OpenTelemetry configuration schemas."
user-invocable: true
license: MIT
compatibility: Designed for Claude Code, Codex or similar harness, and for projects using Golang.
metadata:
  author: opentelemetry-contrib
  version: "1.0.0"
  openclaw:
    emoji: "📡"
    homepage: https://github.com/open-telemetry/opentelemetry-go-contrib
    requires:
      bins:
        - go
    install: []
allowed-tools: Read Edit Write Glob Grep Bash(go:*) Bash(golangci-lint:*) Bash(git:*) Agent AskUserQuestion
paths:
  - "**/*.go"
---

**Persona:** You are a Go OpenTelemetry expert. You implement declarative configuration patterns that follow the OpenTelemetry specification, ensuring proper SDK setup, validation, and environment variable support.

**Modes:**

- **Implement mode** — creating new OpenTelemetry configuration parsing or SDK setup code. Follow the best practices sequentially; ensure proper validation and error handling.
- **Review mode** — reviewing OpenTelemetry configuration code. Check for schema compliance, validation completeness, and proper error handling.
- **Debug mode** — troubleshooting OpenTelemetry configuration issues. Verify schema compliance, environment variable substitution, and provider setup.

> **Community default.** A company skill that explicitly supersedes `golang-otelconf` skill takes precedence.

# OpenTelemetry Declarative Configuration in Go

This skill guides the implementation of OpenTelemetry declarative configuration in Go applications. Follow these principles to create robust, spec-compliant configuration parsing and SDK setup.

## Best Practices Summary

1. **Follow the OpenTelemetry Configuration schema** — use the official JSON Schema for configuration structure
2. **Support environment variable substitution** — allow `${ENV_VAR}` syntax in configuration files
3. **Implement custom unmarshaling** — handle complex types with validation during unmarshaling
4. **Validate configuration at parse time** — catch errors early with comprehensive validation
5. **Use functional options for SDK setup** — allow programmatic configuration alongside file-based configuration
6. **Support multiple configuration formats** — handle both YAML and JSON configuration files
7. **Provide meaningful error messages** — include field names and validation details in errors
8. **Handle optional fields gracefully** — use sensible defaults for omitted configuration
9. **Implement proper shutdown** — ensure all providers are properly shut down
10. **Test configuration parsing** — verify parsing works with various configuration inputs
11. **Use struct tags for serialization** — leverage `yaml` and `json` tags for automatic marshaling/unmarshaling
12. **Handle optional fields with pointers** — distinguish between zero values and omitted values

## Configuration Schema Structure

The OpenTelemetry Configuration schema defines a standard structure for configuring the SDK:

```yaml
file_format: "0.1"
disabled: false
resource:
  attributes:
    - name: service.name
      value: my-service
      type: string
logger_provider:
  processors:
    - batch:
        exporter:
          otlp:
            protocol: grpc
            endpoint: localhost:4317
meter_provider:
  readers:
    - periodic:
        interval: 5000
        exporter:
          otlp:
            protocol: grpc
            endpoint: localhost:4317
tracer_provider:
  processors:
    - batch:
        exporter:
          otlp:
            protocol: grpc
            endpoint: localhost:4317
propagator:
  composite:
    - tracecontext: {}
    - baggage: {}
```

## Implementation Patterns

### Configuration Parsing

Implement custom unmarshaling for complex types:

```go
type Configuration struct {
    FileFormat      string            `yaml:"file_format" json:"file_format"`
    Disabled        *bool             `yaml:"disabled,omitempty" json:"disabled,omitempty"`
    Resource        *Resource         `yaml:"resource,omitempty" json:"resource,omitempty"`
    LoggerProvider  *LoggerProvider   `yaml:"logger_provider,omitempty" json:"logger_provider,omitempty"`
    MeterProvider   *MeterProvider    `yaml:"meter_provider,omitempty" json:"meter_provider,omitempty"`
    TracerProvider  *TracerProvider   `yaml:"tracer_provider,omitempty" json:"tracer_provider,omitempty"`
    Propagator      *Propagator       `yaml:"propagator,omitempty" json:"propagator,omitempty"`
}

func (c *Configuration) UnmarshalYAML(node *yaml.Node) error {
    // Validate required fields
    if !hasYAMLMapKey(node, "file_format") {
        return newErrRequired(c, "file_format")
    }
    
    // Use type alias to prevent infinite recursion
    type Plain Configuration
    var plain Plain
    if err := node.Decode(&plain); err != nil {
        return errors.Join(newErrUnmarshal(c), err)
    }
    
    *c = Configuration(plain)
    return nil
}
```

### Environment Variable Substitution

Support environment variable substitution in configuration files:

```go
func SubstituteEnvVars(data []byte) ([]byte, error) {
    result := string(data)
    
    // Find all ${ENV_VAR} patterns
    re := regexp.MustCompile(`\$\{([^}]+)\}`)
    matches := re.FindAllStringSubmatch(result, -1)
    
    for _, match := range matches {
        envVar := match[1]
        value := os.Getenv(envVar)
        if value == "" {
            return nil, fmt.Errorf("environment variable %s not set", envVar)
        }
        result = strings.ReplaceAll(result, match[0], value)
    }
    
    return []byte(result), nil
}
```

### SDK Provider Creation

Create SDK providers from configuration:

```go
func NewSDK(cfg Configuration) (*SDK, error) {
    if cfg.Disabled != nil && *cfg.Disabled {
        return &SDK{
            loggerProvider: nooplog.LoggerProvider{},
            meterProvider:  noopmetric.MeterProvider{},
            tracerProvider: nooptrace.TracerProvider{},
            propagator:     propagation.NewCompositeTextMapPropagator(),
        }, nil
    }
    
    // Create resource
    res, err := createResource(cfg.Resource)
    if err != nil {
        return nil, fmt.Errorf("create resource: %w", err)
    }
    
    // Create providers
    mp, mpShutdown, err := createMeterProvider(cfg.MeterProvider, res)
    if err != nil {
        return nil, fmt.Errorf("create meter provider: %w", err)
    }
    
    tp, tpShutdown, err := createTracerProvider(cfg.TracerProvider, res)
    if err != nil {
        mpShutdown(context.Background())
        return nil, fmt.Errorf("create tracer provider: %w", err)
    }
    
    lp, lpShutdown, err := createLoggerProvider(cfg.LoggerProvider, res)
    if err != nil {
        mpShutdown(context.Background())
        tpShutdown(context.Background())
        return nil, fmt.Errorf("create logger provider: %w", err)
    }
    
    return &SDK{
        meterProvider:  mp,
        tracerProvider: tp,
        loggerProvider: lp,
        propagator:     createPropagator(cfg.Propagator),
        shutdown: func(ctx context.Context) error {
            return errors.Join(
                mpShutdown(ctx),
                tpShutdown(ctx),
                lpShutdown(ctx),
            )
        },
    }, nil
}
```

### Functional Options Pattern

Use functional options for programmatic configuration:

```go
type ConfigurationOption func(*configOptions) error

func WithResource(res *resource.Resource) ConfigurationOption {
    return func(o *configOptions) error {
        o.resource = res
        return nil
    }
}

func WithMeterProviderOptions(opts ...sdkmetric.Option) ConfigurationOption {
    return func(o *configOptions) error {
        o.meterProviderOptions = append(o.meterProviderOptions, opts...)
        return nil
    }
}

func NewSDKFromOptions(opts ...ConfigurationOption) (*SDK, error) {
    o := &configOptions{
        ctx: context.Background(),
    }
    
    for _, opt := range opts {
        if err := opt(o); err != nil {
            return nil, err
        }
    }
    
    // Create SDK from options
    // ...
}
```

## YAML/JSON Parsing Patterns

### Struct Tag Patterns

Use struct tags for automatic serialization:

```go
type Configuration struct {
    // Required field
    FileFormat string `yaml:"file_format" json:"file_format"`
    
    // Optional field (pointer to distinguish between zero and omitted)
    Disabled *bool `yaml:"disabled,omitempty" json:"disabled,omitempty"`
    
    // Nested struct
    Resource *Resource `yaml:"resource,omitempty" json:"resource,omitempty"`
    
    // Slice of structs
    Processors []Processor `yaml:"processors,omitempty" json:"processors,omitempty"`
}
```

### Custom Unmarshaling for Union Types

Handle discriminated unions with custom unmarshaling:

```go
type Exporter struct {
    Console  *ConsoleExporter  `yaml:"console,omitempty" json:"console,omitempty"`
    OTLP     *OTLPExporter     `yaml:"otlp,omitempty" json:"otlp,omitempty"`
    Prometheus *PrometheusExporter `yaml:"prometheus,omitempty" json:"prometheus,omitempty"`
}

func (e *Exporter) UnmarshalYAML(node *yaml.Node) error {
    // Get the raw map to check which fields are present
    var raw map[string]interface{}
    if err := node.Decode(&raw); err != nil {
        return err
    }
    
    // Check which exporter type is present
    if _, ok := raw["console"]; ok {
        e.Console = &ConsoleExporter{}
        return node.Decode(e.Console)
    }
    if _, ok := raw["otlp"]; ok {
        e.OTLP = &OTLPExporter{}
        return node.Decode(e.OTLP)
    }
    if _, ok := raw["prometheus"]; ok {
        e.Prometheus = &PrometheusExporter{}
        return node.Decode(e.Prometheus)
    }
    
    return fmt.Errorf("unknown exporter type")
}
```

### Required Fields Validation

Validate required fields during unmarshaling:

```go
func (p *Processor) UnmarshalYAML(node *yaml.Node) error {
    // Check for required fields
    if !hasYAMLMapKey(node, "exporter") {
        return newErrRequired(p, "exporter")
    }
    
    // Decode the rest
    type Plain Processor
    var plain Plain
    if err := node.Decode(&plain); err != nil {
        return errors.Join(newErrUnmarshal(p), err)
    }
    
    *p = Processor(plain)
    return nil
}
```

## Validation Patterns

### Field Validation

Validate configuration fields during or after unmarshaling:

```go
func validateConfiguration(cfg *Configuration) error {
    var errs []error
    
    // Validate required fields
    if cfg.FileFormat == "" {
        errs = append(errs, newErrRequired(cfg, "file_format"))
    }
    
    // Validate field values
    if cfg.Disabled != nil && *cfg.Disabled {
        // No further validation needed if disabled
        return nil
    }
    
    // Validate provider configurations
    if cfg.MeterProvider != nil {
        if err := validateMeterProvider(cfg.MeterProvider); err != nil {
            errs = append(errs, fmt.Errorf("meter_provider: %w", err))
        }
    }
    
    if len(errs) > 0 {
        return errors.Join(errs...)
    }
    
    return nil
}
```

### Custom Error Types

Use custom error types for meaningful error messages:

```go
type errRequired struct {
    Object any
    Field  string
}

func (e *errRequired) Error() string {
    return fmt.Sprintf("field %s in %s: required", e.Field, reflect.TypeOf(e.Object))
}

func (e *errRequired) Is(target error) bool {
    t, ok := target.(*errRequired)
    if !ok {
        return false
    }
    return reflect.TypeOf(e.Object) == reflect.TypeOf(t.Object) && e.Field == t.Field
}

func newErrRequired(object any, field string) error {
    return &errRequired{Object: object, Field: field}
}
```

## Error Handling Patterns

### Meaningful Error Messages

Provide detailed error messages with context:

```go
type errUnmarshal struct {
    Object any
}

func (e *errUnmarshal) Error() string {
    return fmt.Sprintf("unmarshal error in %T", e.Object)
}

func (e *errUnmarshal) Is(target error) bool {
    t, ok := target.(*errUnmarshal)
    if !ok {
        return false
    }
    return reflect.TypeOf(e.Object) == reflect.TypeOf(t.Object)
}

func newErrUnmarshal(object any) error {
    return &errUnmarshal{Object: object}
}
```

### Error Wrapping

Wrap errors with context:

```go
func ParseConfiguration(data []byte) (*Configuration, error) {
    // Substitute environment variables
    data, err := SubstituteEnvVars(data)
    if err != nil {
        return nil, fmt.Errorf("substitute environment variables: %w", err)
    }
    
    var cfg Configuration
    if err := yaml.Unmarshal(data, &cfg); err != nil {
        return nil, fmt.Errorf("unmarshal configuration: %w", err)
    }
    
    if err := validateConfiguration(&cfg); err != nil {
        return nil, fmt.Errorf("validate configuration: %w", err)
    }
    
    return &cfg, nil
}
```

## Testing Configuration

### Table-Driven Tests

Use table-driven tests for configuration parsing:

```go
func TestParseConfiguration(t *testing.T) {
    tests := []struct {
        name        string
        input       string
        wantErr     bool
        wantEnabled bool
    }{
        {
            name: "valid minimal configuration",
            input: `
file_format: "0.1"
disabled: false
`,
            wantErr:     false,
            wantEnabled: true,
        },
        {
            name: "valid full configuration",
            input: `
file_format: "0.1"
disabled: false
resource:
  attributes:
    - name: service.name
      value: my-service
      type: string
`,
            wantErr:     false,
            wantEnabled: true,
        },
        {
            name:    "missing file_format",
            input:   `disabled: false`,
            wantErr: true,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            cfg, err := ParseYAML([]byte(tt.input))
            if tt.wantErr {
                assert.Error(t, err)
                return
            }
            
            require.NoError(t, err)
            assert.Equal(t, tt.wantEnabled, cfg.Disabled == nil || !*cfg.Disabled)
        })
    }
}
```

## Cross-References

- → See `samber/cc-skills-golang@golang-observability` for OpenTelemetry tracing and metrics setup
- → See `samber/cc-skills-golang@golang-error-handling` for error handling patterns
- → See `samber/cc-skills-golang@golang-structs-interfaces` for struct design patterns
- → See `samber/cc-skills-golang@golang-testing` for testing patterns

## References

- [OpenTelemetry Configuration Schema](https://github.com/open-telemetry/opentelemetry-configuration)
- [opentelemetry-go-contrib/otelconf](https://github.com/open-telemetry/opentelemetry-go-contrib/tree/main/otelconf)
- [OpenTelemetry Go SDK](https://github.com/open-telemetry/opentelemetry-go)
