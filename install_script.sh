#!/bin/bash

# X-Seti Aug12 2025 - Dynamic Desktop Weather - Installation Script
# For Plasma 6 - Includes weather-widget-2 dependency installation

echo "  Dynamic Desktop Weather/n Installation for Plasma 6/n Based on blackadderkate/weather-widget-2 "

WIDGET_NAME="org.kde.plasma.weathereffects"
BASE_WIDGET_NAME="org.kde.weatherWidget"
PLASMA_DIR="$HOME/.local/share/plasma/plasmoids"
WIDGET_DIR="$PLASMA_DIR/$WIDGET_NAME"
BASE_WIDGET_DIR="$PLASMA_DIR/$BASE_WIDGET_NAME"
TEMP_DIR="/tmp/weather-widget-install"

# Load version configuration if available
if [ -f "plasma-config.env" ]; then
    source plasma-config.env
    echo "Using Plasma $PLASMA_VERSION configuration"
else
    echo "⚠ No plasma-config.env found. Run ./plasma_version_detector.sh first!"
    echo "Assuming Plasma 5 defaults..."
    PLASMA_VERSION=5
    PLASMA_RESTART_CMD="killall plasmashell; kstart5 plasmashell &"
    PACKAGE_INSTALL_CMD="plasmapkg2 --install"
fi

# Check dependencies
check_dependencies() {
    echo "Checking system dependencies..."
    
    # Check for required packages
    local missing_deps=()
    
    command -v git >/dev/null 2>&1 || missing_deps+=("git")
    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Missing dependencies: ${missing_deps[*]}"
        echo "Please install them first:"
        echo "  Ubuntu/Debian: sudo apt install ${missing_deps[*]}"
        echo "  Arch/Manjaro: sudo pacman -S ${missing_deps[*]}"
        exit 1
    fi
    
    echo "✓ All dependencies found"
}

# Install base weather widget based on Plasma version
install_base_widget() {
    echo ""
    if [ "$PLASMA_VERSION" = "6" ]; then
        echo "=== Installing weather-widget-2 for Plasma 6 ==="
        install_weather_widget_2
    else
        echo "=== Installing plasma-applet-weather-widget for Plasma 5 ==="
        install_plasma5_weather_widget
    fi
}

# Install weather-widget-2 (for Plasma 6)
install_weather_widget_2() {
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    if [ -d "$BASE_WIDGET_DIR" ]; then
        echo "weather-widget-2 already installed, updating..."
        cd "$BASE_WIDGET_DIR"
        if [ -d ".git" ]; then
            git pull
        else
            mv "$BASE_WIDGET_DIR" "${BASE_WIDGET_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
    fi
    
    if [ ! -d "$BASE_WIDGET_DIR/.git" ]; then
        echo "Cloning weather-widget-2..."
        git clone https://github.com/blackadderkate/weather-widget-2.git
        mkdir -p "$PLASMA_DIR"
        cp -r weather-widget-2/* "$BASE_WIDGET_DIR/"
        echo "✓ weather-widget-2 installed"
    fi
}

# Install original plasma-applet-weather-widget (for Plasma 5)  
install_plasma5_weather_widget() {
    echo "For Plasma 5, you need the original weather widget by Kotelnik"
    echo "This requires manual compilation. Please run these commands:"
    echo ""
    echo "# Install build dependencies first:"
    echo "  Ubuntu/Debian: sudo apt install cmake make build-essential qtdeclarative5-dev plasma-framework-dev"
    echo "  Arch/Manjaro: sudo pacman -S cmake make qt5-declarative plasma-framework"
    echo ""  
    echo "# Then build and install:"
    echo "git clone https://github.com/kotelnik/plasma-applet-weather-widget"
    echo "cd plasma-applet-weather-widget"
    echo "mkdir build && cd build"
    echo "cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DLIB_INSTALL_DIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON"
    echo "make && sudo make install"
    echo ""
    echo "After installation, re-run this script to continue with the enhanced widget setup."
    
    # Check if already installed
    if [ -d "/usr/share/plasma/plasmoids/org.kde.plasma.weather" ] || [ -d "$HOME/.local/share/plasma/plasmoids/org.kde.plasma.weather" ]; then
        echo "✓ Original weather widget appears to be installed"
        return 0
    else
        echo "❌ Original weather widget not found. Please install it manually first."
        return 1
    fi
}

# Install enhanced weather effects widget
install_enhanced_widget() {
    echo ""
    echo "=== Dynamic Desktop Weather Widget ==="
    
    # Check if widget files exist in current directory
    if [ ! -f "main.qml" ]; then
        echo "❌ main.qml not found in current directory"
        echo "Please ensure you have the following files:"
        echo "  - main.qml"
        echo "  - config.qml" 
        echo "  - main.xml"
        echo "  - metadata.json"
        exit 1
    fi
    
    # Create directory structure
    mkdir -p "$WIDGET_DIR/contents/ui"
    mkdir -p "$WIDGET_DIR/contents/config"
    mkdir -p "$WIDGET_DIR/contents/locale"
    mkdir -p "$WIDGET_DIR/contents/code"
    
    # Copy enhanced widget files
    echo "Installing enhanced widget files..."
    
    # Copy main files
    cp metadata.json "$WIDGET_DIR/" 2>/dev/null || echo "⚠ metadata.json not found"
    cp main.qml "$WIDGET_DIR/contents/ui/" 2>/dev/null || echo "⚠ main.qml not found"
    cp config.qml "$WIDGET_DIR/contents/config/" 2>/dev/null || echo "⚠ config.qml not found"
    cp main.xml "$WIDGET_DIR/contents/config/" 2>/dev/null || echo "⚠ main.xml not found"
    
    # Create integration bridge with base widget
    create_integration_bridge
    
    # Set permissions
    chmod 644 "$WIDGET_DIR/contents/ui/main.qml"
    chmod 644 "$WIDGET_DIR/metadata.json"
    
    echo "✓ Enhanced widget installed"
}

# Create integration bridge between widgets
create_integration_bridge() {
    echo "Creating integration bridge with weather-widget-2..."
    
    # Create weather data bridge
cat > "$WIDGET_DIR/contents/code/WeatherDataBridge.qml" << 'BRIDGE_EOF'
// Integration bridge with weather-widget-2
import QtQuick 2.15
import org.kde.plasma.core 2.1 as PlasmaCore

QtObject {
    id: weatherBridge
    
    // Connect to base weather widget's data source
    property var baseWeatherSource: PlasmaCore.DataSource {
        engine: "weather"
        connectedSources: plasmoid.configuration.location ? [plasmoid.configuration.location] : []
        interval: plasmoid.configuration.updateInterval * 60000
    }
    
    // Expose weather data in enhanced format
    property var weatherData: {
        var data = baseWeatherSource.data[plasmoid.configuration.location] || {}
        return {
            location: plasmoid.configuration.location || "Unknown",
            current: {
                temp: data["Current Conditions"] ? parseFloat(data["Current Conditions"]) : 0,
                condition: data["Current Weather"] || "unknown",
                humidity: data["Humidity"] || "0%",
                pressure: data["Pressure"] || "0 hPa",
                windSpeed: data["Wind Speed"] || "0 km/h",
                visibility: data["Visibility"] || "N/A"
            },
            forecast: parseForecastData(data)
        }
    }
    
    function parseForecastData(data) {
        var forecast = []
        for (var i = 0; i < 7; i++) {
            var dayKey = "Short Forecast Day " + i
            var tempKey = "High Temperature Day " + i
            var lowTempKey = "Low Temperature Day " + i
            
            forecast.push({
                day: formatDay(i),
                temps: [
                    parseFloat(data[lowTempKey]) || 0,
                    parseFloat(data[tempKey]) || 0
                ],
                condition: data[dayKey] || "unknown",
                rain: Math.random() * 5 // Placeholder - enhance based on actual data
            })
        }
        return forecast
    }
    
    function formatDay(offset) {
        var date = new Date()
        date.setDate(date.getDate() + offset)
        return date.toLocaleDateString('en', {weekday: 'short'})
    }
}
BRIDGE_EOF

    # Create effects controller
cat > "$WIDGET_DIR/contents/code/EffectsController.qml" << 'EFFECTS_EOF'
// Desktop effects controller
import QtQuick 2.15
import org.kde.plasma.core 2.1 as PlasmaCore

QtObject {
    id: effectsController
    
    property var executable: PlasmaCore.DataSource {
        engine: "executable"
        connectedSources: []
        
        function exec(command) {
            connectSource(command)
        }
        
        onNewData: {
            disconnectSource(sourceName)
        }
    }
    
    // Apply weather effects based on condition
    function applyWeatherEffects(condition, timeOfDay) {
        var script = "weather-wallpaper-controller"
        
        switch(condition.toLowerCase()) {
            case "rain":
            case "drizzle":
            case "thunderstorm":
                executable.exec(script + " rain " + timeOfDay)
                executable.exec("plasma-apply-colorscheme WeatherRainy")
                break
            case "snow":
                executable.exec(script + " snow " + timeOfDay)
                executable.exec("plasma-apply-colorscheme WeatherSnowy")
                break
            case "clear":
            case "sunny":
            default:
                executable.exec(script + " clear " + timeOfDay)
                executable.exec("plasma-apply-colorscheme WeatherSunny")
                break
        }
    }
    
    // Auto-apply effects based on current weather
    function autoApplyEffects(weatherData) {
        var hour = new Date().getHours()
        var timeOfDay = (hour < 6 || hour > 19) ? "night" : "day"
        
        if (weatherData && weatherData.current) {
            applyWeatherEffects(weatherData.current.condition, timeOfDay)
        }
    }
}
EFFECTS_EOF
}

# Register widget with Plasma
register_widget() {
    echo ""
    echo "=== Registering Widget with Plasma ==="
    
    # Install using plasmapkg2 if available
    if command -v plasmapkg2 >/dev/null 2>&1; then
        echo "Installing widget package..."
        plasmapkg2 --install "$WIDGET_DIR" 2>/dev/null || plasmapkg2 --upgrade "$WIDGET_DIR"
        echo "✓ Widget registered with Plasma"
    else
        echo "⚠ plasmapkg2 not found, widget files copied manually"
        echo "  You may need to restart Plasma to see the widget"
    fi
}

# Create development setup
setup_development() {
    echo ""
    echo "=== Development Setup ==="
    
    cat > "$HOME/weather-widget-development.md" << 'DEV_EOF'
# Weather Widget Development Guide

## Your Fork Development Setup

### 1. Fork the Original Repository
```bash
# Go to: https://github.com/blackadderkate/weather-widget-2
# Click "Fork" to create your own copy
# Clone your fork:
git clone https://github.com/YOUR_USERNAME/weather-widget-2.git
cd weather-widget-2
```

### 2. Development Workflow
```bash
# Create feature branch
git checkout -b enhanced-martian-ui

# Make your changes
# Test on your (Ubuntu/Debian/Manjaro) distros

# Commit and push
git add .
git commit -m "Add Martian UI enhancements and desktop effects"
git push origin enhanced-martian-ui

# Create pull request back to original repo (optional)
```

### 3. Testing Commands

```bash
# Reload widget after changes
plasmapkg2 --upgrade ~/.local/share/plasma/plasmoids/org.kde.plasma.weathereffects

# Restart Plasma to test changes
killall plasmashell; plasmashell &

# Monitor logs for debugging
journalctl --user -f | grep plasma

# Test QML directly
qmlscene main.qml
```

### 4. Widget Installation Paths

- Widget location: ~/.local/share/plasma/plasmoids/org.kde.plasma.weathereffects/
- Base widget: ~/.local/share/plasma/plasmoids/org.kde.weatherWidget/
- Desktop effects: ~/.local/share/kwin/effects/
- Color schemes: ~/.config/color-schemes/

Happy coding! 🌟
DEV_EOF

    echo "✓ Development guide created: ~/weather-widget-development.md"
}

# Main installation function
main() {
    check_dependencies
    install_base_widget
    install_enhanced_widget
    register_widget
    setup_development
    
    echo ""
    echo "====================================================="
    echo "             🎉 Installation Complete! 🎉           "
    echo "====================================================="
    echo ""
    echo "✅ Installed Components:"
    echo "   • weather-widget-2 (base widget)"
    echo "   • Dynamic Desktop Weather Widget"
    echo "   • Integration bridges"
    echo "   • Development setup guide"
    echo ""
    echo "🚀 Next Steps:"
    echo "   1. Run: ./advanced_effects_setup.sh (for desktop effects)"
    echo "   2. Restart Plasma: killall plasmashell; plasmashell &"
    echo "   3. Add widgets: Right-click → Add Widgets"
    echo "   4. Search for 'Weather Effects Widget'"
    echo "   5. Configure location in widget settings"
    echo ""
    echo "📖 Read the development guide:"
    echo "   cat ~/weather-widget-development.md"
    echo ""
    echo "🎨 Available Widgets:"
    echo "   • Weather Widget (original weather-widget-2)"
    echo "   • Weather Effects Widget (your enhanced version)"
    echo ""
    echo "Happy weather monitoring! 🌟"
}

# Run installation
main "$@"
