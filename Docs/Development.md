# Development

>Ultra Hardcore welcomes contributions from developers who share the vision of creating the ultimate hardcore World of Warcraft experience. The project maintains high standards for code quality, performance, and user experience while fostering an inclusive development environment.

## Development Environment Setup

Setting up a development environment for Ultra Hardcore requires familiarity with World of Warcraft addon development and Lua programming. The project uses modern development practices adapted for the WoW addon ecosystem.

**Prerequisites**:
- World of Warcraft Classic Era client
- Text editor with Lua syntax highlighting (VS Code, Sublime Text, or Vim)
- Git for version control
- Basic understanding of WoW addon architecture
- Familiarity with Lua programming language

**Development Setup Process**:

1. **Fork and Clone the Repository**
   ```bash
   # Fork the repository on GitHub first
   git clone https://github.com/yourusername/UltraHardcore.git
   cd UltraHardcore
   
   # Set up upstream remote
   git remote add upstream https://github.com/bonniesdad/UltraHardcore.git
   ```

2. **Create Development Symlink**
   ```bash
   # Create symlink in WoW AddOns directory (Windows)
   mklink /D "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\UltraHardcore" "C:\path\to\your\UltraHardcore"
   
   # Create symlink on macOS/Linux
   ln -s /path/to/your/UltraHardcore "/Applications/World of Warcraft/_classic_era_/Interface/AddOns/UltraHardcore"
   ```

3. **Install Development Tools**
   ```bash
   # Install Node.js dependencies for linting and formatting
   npm install
   
   # Set up pre-commit hooks
   npm run setup-hooks
   ```

## Code Organization and Standards

Ultra Hardcore follows a strict code organization philosophy that emphasizes modularity, readability, and maintainability. Understanding this structure is essential for effective contribution.

**File Naming Conventions**:
- Core functionality: `PascalCase.lua` (e.g., `DeathIndicator.lua`)
- Utility functions: `Utils/PascalCase.lua` (e.g., `Utils/RotateScreenEffect.lua`)
- Database operations: `DB/PascalCase.lua` (e.g., `DB/LoadDBData.lua`)
- Settings management: `Settings/PascalCase.lua` (e.g., `Settings/Settings.lua`)

**Code Style Guidelines**:

```lua
-- Function naming: PascalCase for public functions, camelCase for private
function DeathIndicator(self, event, unit, showTunnelVision)
    local healthPercent = (UnitHealth('player') / UnitHealthMax('player')) * 100
    
    if showTunnelVision then
        if healthPercent <= 20 then
            ApplyDeathIndicatorChange(10)
        elseif healthPercent <= 40 then
            ApplyDeathIndicatorChange(14)
        end
    else
        RemoveDeathIndicator()
    end
end

-- Local variables for performance optimization
local function updateHealthIndicator(unit, healthPercent)
    -- Implementation details
end
```

**Documentation Standards**:
- All public functions must include comprehensive comments
- Complex algorithms require step-by-step explanation
- Event handlers must document their trigger conditions
- Configuration options need usage examples

## Testing and Quality Assurance

Ultra Hardcore maintains rigorous testing standards to ensure stability and performance across different game scenarios and hardware configurations.

**Testing Framework**:
The addon includes a custom testing framework designed specifically for World of Warcraft addon validation:

```lua
-- Test framework example
UHCTestSuite = {
    testDeathIndicator = function()
        -- Simulate health loss
        local mockHealth = 0.3
        DeathIndicator(nil, "UNIT_HEALTH_FREQUENT", "player", true)
        
        -- Verify overlay application
        assert(deathOverlayActive == true, "Death overlay should be active at 30% health")
    end,
    
    testCriticalHitEffect = function()
        -- Simulate critical hit event
        OnCombatLogEvent(nil, "SPELL_DAMAGE", nil, nil, nil, nil, nil, nil, true)
        
        -- Verify screen rotation
        assert(screenRotationActive == true, "Screen rotation should activate on critical hit")
    end
}
```

**Manual Testing Procedures**:
1. **Core Functionality Testing**: Verify all primary features work correctly
2. **Edge Case Testing**: Test extreme scenarios (very low health, multiple critical hits)
3. **Performance Testing**: Monitor frame rate impact during intensive scenarios
4. **Compatibility Testing**: Ensure compatibility with popular addons
5. **User Experience Testing**: Validate that the hardcore experience remains challenging but fair

**Automated Testing**:
```bash
# Run automated test suite
npm run test

# Run performance benchmarks
npm run benchmark

# Validate code style
npm run lint
```

## Contributing Guidelines

Ultra Hardcore follows a structured contribution process that ensures code quality while welcoming developers of all skill levels.

**Contribution Workflow**:

1. **Issue Discussion**: Before implementing features, discuss your ideas in GitHub issues
2. **Feature Branch**: Create a descriptive branch name (e.g., `feature/enhanced-death-indicator`)
3. **Implementation**: Follow coding standards and include comprehensive tests
4. **Documentation**: Update relevant documentation and code comments
5. **Pull Request**: Submit a detailed pull request with clear description and testing notes

**Pull Request Requirements**:
- Clear description of changes and motivation
- Comprehensive testing of new functionality
- Documentation updates for user-facing changes
- Performance impact assessment
- Compatibility verification with existing features

**Code Review Process**:
All contributions undergo thorough code review focusing on:
- Code quality and adherence to project standards
- Performance implications and optimization opportunities
- User experience impact and hardcore philosophy alignment
- Security considerations and addon safety
- Documentation completeness and accuracy

## Development Tools and Utilities

Ultra Hardcore provides several development tools to streamline the contribution process:

**Debugging Utilities**:
```lua
-- Debug logging system
UHCDebug = {
    log = function(message, level)
        if GLOBAL_SETTINGS.debugMode then
            print(string.format("[UHC-%s] %s", level or "INFO", message))
        end
    end,
    
    dumpSettings = function()
        -- Output current settings for debugging
        for key, value in pairs(GLOBAL_SETTINGS) do
            UHCDebug.log(string.format("%s: %s", key, tostring(value)))
        end
    end
}
```

**Performance Profiling**:
```lua
-- Performance monitoring
UHCProfiler = {
    startTimer = function(name)
        UHCProfiler.timers[name] = GetTime()
    end,
    
    endTimer = function(name)
        local elapsed = GetTime() - (UHCProfiler.timers[name] or 0)
        UHCDebug.log(string.format("Timer %s: %.3fms", name, elapsed * 1000))
    end
}
```

**Development Configuration**:
```lua
-- Development-specific settings
if GLOBAL_SETTINGS.developmentMode then
    GLOBAL_SETTINGS.debugMode = true
    GLOBAL_SETTINGS.enableProfiling = true
    GLOBAL_SETTINGS.skipIntroAnimations = true
    GLOBAL_SETTINGS.fastTestMode = true
end
```