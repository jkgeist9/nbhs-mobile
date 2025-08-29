# Font Setup Instructions

## To complete the font setup in Xcode:

1. **Open the project in Xcode**
   - Open `nbhs-mobile.xcodeproj` in Xcode

2. **Add fonts to the project**
   - In the Project Navigator, right-click on the `nbhs-mobile` folder
   - Select "Add Files to 'nbhs-mobile'"
   - Navigate to the `Fonts` folder and select all 6 font files
   - Make sure "Add to target" is checked for `nbhs-mobile`
   - Click "Add"

3. **Register fonts in Info.plist**
   - In Xcode, select the `nbhs-mobile` project in the navigator
   - Click on the `nbhs-mobile` target
   - Go to the "Info" tab
   - Find "Custom iOS Target Properties" section
   - Click the "+" button to add a new key
   - Type `UIAppFonts` and press Enter
   - Set the type to "Array"
   - Expand the array and add 6 string items:
     - `Montserrat-Regular.ttf`
     - `Montserrat-Medium.ttf`
     - `Montserrat-SemiBold.ttf`
     - `Montserrat-Bold.ttf`
     - `Merriweather-Regular.ttf`
     - `Merriweather-Bold.ttf`

4. **Build and test**
   - Clean the build folder (Product > Clean Build Folder)
   - Build and run the app
   - Check the console for font loading messages

The Typography.swift file is already configured to use these fonts correctly.