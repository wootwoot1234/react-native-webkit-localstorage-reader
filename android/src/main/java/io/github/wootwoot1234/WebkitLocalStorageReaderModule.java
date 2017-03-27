package io.github.wootwoot1234;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableNativeMap;

import java.io.File;
import java.nio.charset.Charset;


public class WebkitLocalStorageReaderModule extends ReactContextBaseJavaModule {

    public WebkitLocalStorageReaderModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "WebkitLocalStorageReader";
    }

    @ReactMethod
    public void get(Promise promise) {
        WritableMap kv = new WritableNativeMap();
        String dataDir = getReactApplicationContext().getApplicationInfo().dataDir;
        File localstorage = new File(dataDir + "/app_webview/Local Storage/file__0.localstorage");

        if (!localstorage.exists()) {
            promise.resolve(kv);
            return;
        }

        Cursor cursor = null;
        SQLiteDatabase db = null;
        try {
            File dbfile = getReactApplicationContext().getDatabasePath(localstorage.getPath());
            dbfile.setWritable(true);
            db = SQLiteDatabase.openDatabase(dbfile.getAbsolutePath(), null, SQLiteDatabase.OPEN_READWRITE);

            String sql = "SELECT key,value FROM ItemTable";
            cursor = db.rawQuery(sql, null);
            cursor.moveToFirst();
            while (!cursor.isAfterLast()) {
                String key = cursor.getString(0);
                byte[] itemByteArray = cursor.getBlob(1);
                String value = new String(itemByteArray, Charset.forName("UTF-16LE"));

                kv.putString(key, value);
                cursor.moveToNext();
            }
            promise.resolve(kv);
        } catch (Exception e) {
            e.printStackTrace();
            promise.resolve(kv);
        } finally {
            if (cursor != null) {
                cursor.close();
            }
            if (db != null) {
                db.close();
            }
        }
    }
}
