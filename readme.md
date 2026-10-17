# X-Seti Aug12 2025 - Dynamic Desktop Weather. (Discontinued) 
# This project has been replaced with https://github.com/X-Seti/Atmosphere

How to install;
# 1. Make scripts executable
chmod +x install_script.sh
chmod +x advanced_effects_setup.sh
chmod +x plasma_version_detector.sh

# 2. Run main installer (installs weather-widget-2 + your enhanced widget)
./install_script.sh

# 3. Run desktop effects setup
./advanced_effects_setup.sh

# 4. Restart Plasma
killall plasmashell; kstart5 plasmashell &


# Follow these 4 steps for KDE Plasma5

# 1. Make scripts executable
chmod +x install_script.sh
chmod +x advanced_effects_setup.sh
chmod +x plasma_version_detector.sh

# 2. Run version detection FIRST
./plasma_version_detector.sh

# 3. For Plasma 5 systems, manually install base widget:
git clone https://github.com/X-Seti/Atmosphere
cd Atmosphere
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DLIB_INSTALL_DIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make && sudo make install

# 4. Then run the enhanced installer
./install_script.sh
./advanced_effects_setup.sh
