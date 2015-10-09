# `react-native-webkit-localstorage-reader`

A react-native wrapper for reading existing localstorage created by apps built with cordova/phonegap.  This is useful if you built an app in cordova/phonegap (a webkit app) and now want access the localstorage from previous versions of the app in react native.

# Notes

- Please feel free to fork and add features or fix bugs then send me a pull request.

### Add it to your project

1. Run `npm install wootwoot1234/react-native-webkit-localstorage-reader --save`.

2. Open your project in XCode, right click on `Libraries`, click `Add Files to "Your Project Name"` and add `WebkitLocalStorageReader.xcodeproj`. (situated in `node_modules/react-native-webkit-localstorage-reader`) [(This](http://url.brentvatne.ca/jQp8) then [this](http://url.brentvatne.ca/1gqUD), just with WebkitLocalStorageReader).

3. Link `libWebkitLocalStorageReader.a` with your Libraries. To do that, click on your project folder, select `Build Phases` in the top bar, scroll to `Link Binary with Libraries`, press the `+` at the very bottom and add `libWebkitLocalStorageReader.a` from the `node_modules/react-native-webkit-localstorage-reader/WebkitLocalStorageReader` folder. [(Screenshot)](http://url.brentvatne.ca/17Xfe).

4. Whenever you want to use it within React code now you just have to do: `var WebkitLocalStorageReader = require('NativeModules').WebkitLocalStorageReader;`


## API

### Read Localstorage

You have to load the products first to get the correctly internationalized name and price in the correct currency.

```javascript
var WebkitLocalStorageReader = require('NativeModules').WebkitLocalStorageReader;
WebkitLocalStorageReader.get((jsonString) => {
    var jsonObj = JSON.parse(jsonString);
    console.log(jsonObj);
});
```

## Testing

To test make sure you install the new version of the app on top of an existing version (make sure the Bundle Identifiers match).  There will be no localstorage file if you try to run this code in a brand new app or an app that wasn't previously opened as a cordova/phonegap app.
