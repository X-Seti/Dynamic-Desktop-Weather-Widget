#!/bin/bash

# # X-Seti Aug12 2025 - Dynamic Desktop Weather -  Integration for Weather Widgets
# Integrates with KDE Plasma 5 & 6, extends existing weather-widget /2

WIDGET_DIR="$HOME/.local/share/plasma/plasmoids/org.kde.plasma.weathereffects"
EFFECTS_DIR="$HOME/.local/share/kwin/effects"
CONFIG_DIR="$HOME/.config"

# Color schemes for different weather conditions
create_weather_color_schemes() {
    echo "Creating weather-based color schemes..."
    
    mkdir -p "$CONFIG_DIR/color-schemes"
    
    # Sunny Day Scheme (bright, warm)
cat > "$CONFIG_DIR/color-schemes/WeatherSunny.colors" << 'EOF'
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=239,240,241
BackgroundNormal=252,252,252
DecorationFocus=61,174,233
DecorationHover=147,206,233
ForegroundActive=61,174,233
ForegroundInactive=127,140,141
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=35,38,39
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[General]
ColorScheme=WeatherSunny
Name=Weather Sunny
shadeSortColumn=true

[Colors:Window]
BackgroundAlternate=239,240,241
BackgroundNormal=252,252,252
DecorationFocus=61,174,233
DecorationHover=147,206,233
ForegroundActive=61,174,233
ForegroundInactive=127,140,141
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=35,38,39
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141
EOF

    # Rainy Day Scheme (cool, muted)
cat > "$CONFIG_DIR/color-schemes/WeatherRainy.colors" << 'EOF'
[Colors:Button]
BackgroundAlternate=64,69,82
BackgroundNormal=49,54,67
DecorationFocus=61,174,233
DecorationHover=147,206,233
ForegroundActive=61,174,233
ForegroundInactive=127,140,141
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=211,218,227
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[General]
ColorScheme=WeatherRainy
Name=Weather Rainy

[Colors:Window]
BackgroundAlternate=64,69,82
BackgroundNormal=49,54,67
ForegroundNormal=211,218,227
EOF

    # Snowy Scheme (bright, clean)
cat > "$CONFIG_DIR/color-schemes/WeatherSnowy.colors" << 'EOF'
[Colors:Button]
BackgroundAlternate=248,248,255
BackgroundNormal=255,255,255
ForegroundNormal=32,32,32

[General]
ColorScheme=WeatherSnowy
Name=Weather Snowy

[Colors:Window]
BackgroundAlternate=248,248,255
BackgroundNormal=255,255,255
ForegroundNormal=32,32,32
EOF
}

# Custom KWin effects for weather
create_custom_effects() {
    echo "Creating custom KWin effects..."
    
    mkdir -p "$EFFECTS_DIR/rain"
    mkdir -p "$EFFECTS_DIR/snow"
    mkdir -p "$EFFECTS_DIR/weather_dim"

    # Rain Effect
cat > "$EFFECTS_DIR/rain/metadata.json" << 'EOF'
{
    "KPlugin": {
        "Id": "rain",
        "Name": "Rain Effect",
        "Description": "Animated rain drops on screen",
        "Authors": [
            {
                "Name": "X-Seti",
                "Email": "keithvc1972@hotmail.com"
            }
        ],
        "Category": "Appearance",
        "License": "GPL",
        "Version": "1.0"
    }
}
EOF

cat > "$EFFECTS_DIR/rain/rain.js" << 'EOF'
// Rain Effect for KWin
var raindrops = [];
var maxDrops = 150;
var canvas;

function init() {
    canvas = effect.createCanvas();
    canvas.width = workspace.displayWidth;
    canvas.height = workspace.displayHeight;
    
    // Initialize raindrops
    for (var i = 0; i < maxDrops; i++) {
        raindrops.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height - canvas.height,
            speed: 2 + Math.random() * 8,
            length: 10 + Math.random() * 20,
            opacity: 0.3 + Math.random() * 0.4
        });
    }
    
    animate();
}

function animate() {
    var ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Draw and update raindrops
    for (var i = 0; i < raindrops.length; i++) {
        var drop = raindrops[i];
        
        // Draw raindrop
        ctx.strokeStyle = 'rgba(173, 216, 230, ' + drop.opacity + ')';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(drop.x, drop.y);
        ctx.lineTo(drop.x - 2, drop.y + drop.length);
        ctx.stroke();
        
        // Update position
        drop.y += drop.speed;
        drop.x -= 0.5; // Wind effect
        
        // Reset if off screen
        if (drop.y > canvas.height + drop.length) {
            drop.y = -drop.length;
            drop.x = Math.random() * canvas.width;
        }
    }
    
    // Continue animation
    if (effect.active) {
        setTimeout(animate, 50); // ~20 FPS
    }
}

function cleanup() {
    if (canvas) {
        canvas.destroy();
    }
}

// Effect lifecycle
effects.windowActivated.connect(function() {
    if (effect.active) {
        animate();
    }
});
EOF

    # Snow Effect
cat > "$EFFECTS_DIR/snow/snow.js" << 'EOF'
// Snow Effect for KWin
var snowflakes = [];
var maxFlakes = 100;
var canvas;

function init() {
    canvas = effect.createCanvas();
    canvas.width = workspace.displayWidth;
    canvas.height = workspace.displayHeight;
    
    // Initialize snowflakes
    for (var i = 0; i < maxFlakes; i++) {
        snowflakes.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height - canvas.height,
            speed: 1 + Math.random() * 3,
            size: 2 + Math.random() * 4,
            drift: (Math.random() - 0.5) * 2,
            opacity: 0.6 + Math.random() * 0.4
        });
    }
    
    animate();
}

function animate() {
    var ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Draw and update snowflakes
    for (var i = 0; i < snowflakes.length; i++) {
        var flake = snowflakes[i];
        
        // Draw snowflake
        ctx.fillStyle = 'rgba(255, 255, 255, ' + flake.opacity + ')';
        ctx.beginPath();
        ctx.arc(flake.x, flake.y, flake.size, 0, 2 * Math.PI);
        ctx.fill();
        
        // Update position
        flake.y += flake.speed;
        flake.x += flake.drift;
        
        // Reset if off screen
        if (flake.y > canvas.height + flake.size) {
            flake.y = -flake.size;
            flake.x = Math.random() * canvas.width;
        }
        if (flake.x < -flake.size) {
            flake.x = canvas.width + flake.size;
        } else if (flake.x > canvas.width + flake.size) {
            flake.x = -flake.size;
        }
    }
    
    // Continue animation
    if (effect.active) {
        setTimeout(animate, 60); // ~17 FPS
    }
}

function cleanup() {
    if (canvas) {
        canvas.destroy();
    }
}
EOF
}

# Desktop background effects
create_wallpaper_effects() {
    echo "Creating wallpaper effect scripts..."
    
    mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/weather-wallpaper-controller" << 'EOF'
#!/bin/bash

# Weather Wallpaper Controller
# Changes wallpaper and effects based on weather conditions

WALLPAPER_DIR="$HOME/.local/share/wallpapers/weather"
CONFIG_FILE="$HOME/.config/weather-effects.conf"

# Create wallpaper directory
mkdir -p "$WALLPAPER_DIR"

# Function to apply weather-based wallpaper
apply_weather_wallpaper() {
    local weather_condition="$1"
    local time_of_day="$2"  # day/night
    
    case "$weather_condition" in
        "rain"|"thunderstorm")
            local wallpaper="$WALLPAPER_DIR/rainy_${time_of_day}.jpg"
            if [ ! -f "$wallpaper" ]; then
                # Generate rainy wallpaper effect
                convert "$WALLPAPER_DIR/base_${time_of_day}.jpg" \
                    -colorspace Gray -tint 70x0+0+20 \
                    -modulate 80,90,100 \
                    "$wallpaper" 2>/dev/null || echo "ImageMagick not found"
            fi
            ;;
        "snow")
            local wallpaper="$WALLPAPER_DIR/snowy_${time_of_day}.jpg"
            if [ ! -f "$wallpaper" ]; then
                # Generate snowy wallpaper effect
                convert "$WALLPAPER_DIR/base_${time_of_day}.jpg" \
                    -modulate 110,80,100 \
                    -colorspace sRGB -channel RGB -blur 0x0.5 \
                    "$wallpaper" 2>/dev/null || echo "ImageMagick not found"
            fi
            ;;
        "clear"|"sunny")
            local wallpaper="$WALLPAPER_DIR/sunny_${time_of_day}.jpg"
            if [ ! -f "$wallpaper" ]; then
                # Generate sunny wallpaper effect
                convert "$WALLPAPER_DIR/base_${time_of_day}.jpg" \
                    -modulate 105,110,100 \
                    -sigmoidal-contrast 3,50% \
                    "$wallpaper" 2>/dev/null || echo "ImageMagick not found"
            fi
            ;;
    esac
    
    # Apply wallpaper via D-Bus
    if [ -f "$wallpaper" ]; then
        qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            var allDesktops = desktops();
            for (i=0;i<allDesktops.length;i++) {
                d = allDesktops[i];
                d.wallpaperPlugin = \"org.kde.image\";
                d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");
                d.writeConfig(\"Image\", \"file://$wallpaper\");
            }
        "
    fi
}

# Function to apply screen dimming
apply_screen_dimming() {
    local dim_level="$1"  # 0.0 to 1.0
    
    # Use compositor effects for dimming
    qdbus org.kde.kwin /KWin org.kde.kwin.Compositing.toggleEffect dimscreen
    
    # Alternative: adjust screen brightness via xrandr
    local brightness=$(echo "1.0 - $dim_level" | bc -l)
    xrandr --output $(xrandr | grep " connected" | cut -f1 -d " " | head -1) --brightness "$brightness" 2>/dev/null || echo "xrandr dimming failed"
}

# Main function
case "$1" in
    "rain")
        apply_weather_wallpaper "rain" "$2"
        # Apply rain effect
        qdbus org.kde.kwin /KWin toggleEffect rain
        ;;
    "snow")
        apply_weather_wallpaper "snow" "$2"
        # Apply snow effect
        qdbus org.kde.kwin /KWin toggleEffect snow
        ;;
    "clear")
        apply_weather_wallpaper "clear" "$2"
        # Clear all effects
        qdbus org.kde.kwin /KWin toggleEffect rain false
        qdbus org.kde.kwin /KWin toggleEffect snow false
        apply_screen_dimming 0.0
        ;;
    "dim")
        apply_screen_dimming "$2"
        ;;
    *)
        echo "Usage: $0 {rain|snow|clear|dim} [day|night|dim_level]"
        echo "Controls desktop weather effects and wallpapers"
        ;;
esac
EOF

    chmod +x "$HOME/.local/bin/weather-wallpaper-controller"
}

# Plasma theme integration
create_plasma_themes() {
    echo "Creating weather-based Plasma themes..."
    
    THEME_DIR="$HOME/.local/share/plasma/desktoptheme"
    
    # Martian Theme (inspired by The Martian movie)
    mkdir -p "$THEME_DIR/martian-weather"
    
cat > "$THEME_DIR/martian-weather/metadata.desktop" << 'EOF'
[Desktop Entry]
Name=Dynamic Desktop Weather
Comment="The Martian" theme included with weather integration
X-KDE-PluginInfo-Author=X-Seti
X-KDE-PluginInfo-Email=keithvc1972@hotmail.com
X-KDE-PluginInfo-Name=Dynamic Desktop Weather
X-KDE-PluginInfo-Version=1.0
X-KDE-PluginInfo-License=GPL
X-KDE-PluginInfo-Category=Plasma Theme

[ContrastEffect]
enabled=true
contrast=0.2
intensity=1.4
saturation=1.7
EOF

    # Create color variations for different weather
cat > "$THEME_DIR/martian-weather/colors" << 'EOF'
[Colors:Button]
BackgroundNormal=26,35,46
BackgroundAlternate=64,181,246
ForegroundNormal=205,214,244
ForegroundActive=64,181,246

[Colors:Selection]
BackgroundNormal=64,181,246
ForegroundNormal=10,14,20

[Colors:Window]
BackgroundNormal=26,35,46
BackgroundAlternate=16,20,25
ForegroundNormal=205,214,244
EOF
}

# System integration scripts
create_system_integration() {
    echo "Creating system integration..."
    
cat > "$HOME/.local/bin/weather-system-integration" << 'EOF'
#!/bin/bash

# System-wide weather integration for KDE Plasma 6

# Monitor weather changes and apply system effects
monitor_weather() {
    local weather_api_key="YOUR_API_KEY"  # Replace with actual API key
    local location="Tenbury Wells,UK"
    
    while true; do
        # Fetch weather data (using OpenWeatherMap API example)
        local weather_data=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=$location&appid=$weather_api_key&units=metric")
        
        if [ $? -eq 0 ]; then
            local condition=$(echo "$weather_data" | jq -r '.weather[0].main' 2>/dev/null)
            local temp=$(echo "$weather_data" | jq -r '.main.temp' 2>/dev/null)
            local time_of_day=$(date +%H)
            
            # Determine day/night
            if [ "$time_of_day" -lt 6 ] || [ "$time_of_day" -gt 19 ]; then
                local time_period="night"
            else
                local time_period="day"
            fi
            
            # Apply effects based on weather
            case "$condition" in
                "Rain"|"Drizzle"|"Thunderstorm")
                    weather-wallpaper-controller rain "$time_period"
                    plasma-apply-colorscheme WeatherRainy
                    ;;
                "Snow")
                    weather-wallpaper-controller snow "$time_period"
                    plasma-apply-colorscheme WeatherSnowy
                    ;;
                "Clear"|"Clouds")
                    weather-wallpaper-controller clear "$time_period"
                    plasma-apply-colorscheme WeatherSunny
                    ;;
            esac
            
            # Apply night dimming
            if [ "$time_period" = "night" ]; then
                weather-wallpaper-controller dim 0.3
            else
                weather-wallpaper-controller dim 0.0
            fi
        fi
        
        # Wait before next check (5 minutes)
        sleep 300
    done
}

# Install as systemd user service
install_service() {
    mkdir -p "$HOME/.config/systemd/user"
    
cat > "$HOME/.config/systemd/user/weather-integration.service" << 'EOFS'
[Unit]
Description=Weather Desktop Integration
After=graphical-session.target

[Service]
Type=simple
ExecStart=%h/.local/bin/weather-system-integration monitor
Restart=always
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
EOFS

    systemctl --user daemon-reload
    systemctl --user enable weather-integration.service
    echo "Weather integration service installed. Start with:"
    echo "systemctl --user start weather-integration.service"
}

case "$1" in
    "monitor")
        monitor_weather
        ;;
    "install")
        install_service
        ;;
    "start")
        systemctl --user start weather-integration.service
        ;;
    "stop")
        systemctl --user stop weather-integration.service
        ;;
    *)
        echo "Usage: $0 {monitor|install|start|stop}"
        ;;
esac
EOF

    chmod +x "$HOME/.local/bin/weather-system-integration"
}

# Main installation function
main() {
    echo "=== Dynamic Desktop Weather Setup ==="
    echo "Setting up advanced desktop integration..."
    
    create_weather_color_schemes
    create_custom_effects
    create_wallpaper_effects
    create_plasma_themes
    create_system_integration
    
    echo ""
    echo "=== Installation Complete! ==="
    echo ""
    echo "Available commands:"
    echo "• weather-wallpaper-controller - Manual wallpaper/effect control"
    echo "• weather-system-integration install - Install auto-monitoring service"
    echo ""
    echo "Color schemes installed:"
    echo "• WeatherSunny - Bright, warm colors"
    echo "• WeatherRainy - Cool, muted colors"
    echo "• WeatherSnowy - Clean, bright colors"
    echo ""
    echo "Apply with: plasma-apply-colorscheme WeatherRainy"
    echo ""
    echo "Next steps:"
    echo "1. Configure your weather API key in weather-system-integration"
    echo "2. Add base wallpapers to ~/.local/share/wallpapers/weather/"
    echo "3. Install the Plasma widget using the previous installation script"
    echo "4. Enable KWin compositor effects in System Settings"
    echo ""
    echo "For automatic weather monitoring:"
    echo "weather-system-integration install"
    echo "weather-system-integration start"
}

# Run main installation
main "$@"
