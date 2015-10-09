#import "WebkitLocalStorageReader.h"

@implementation WebkitLocalStorageReader

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(get:(RCTResponseSenderBlock)callback)
{
    NSString *databaseName = @"file__0.localstorage";

    //Get Library path
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                                NSUserDomainMask, YES);
    NSString *libraryDir = [libraryPaths objectAtIndex:0];

    // Acording to this link, the database might be located in the cache folder but it wasn't for me.
    //https://gist.github.com/shazron/2127546
    NSString *databasePath = [libraryDir
                              stringByAppendingPathComponent:@"WebKit/LocalStorage/"];
                                      //stringByAppendingPathComponent:@"Caches/"];

    NSString *databaseFile = [databasePath
                                 stringByAppendingPathComponent:databaseName];

    BOOL webkitDb;

    NSFileManager *fileManager = [NSFileManager defaultManager];

    webkitDb = [fileManager fileExistsAtPath:databaseFile];

    if (webkitDb) {

        sqlite3* db = NULL;
        sqlite3_stmt* stmt =NULL;
        int rc=0;
        NSString *jsonStringMaster = @"";
        // int len = 0;
        rc = sqlite3_open_v2([databaseFile UTF8String], &db, SQLITE_OPEN_READONLY , NULL);
        if (SQLITE_OK != rc)
        {
            sqlite3_close(db);
            NSLog(@"Failed to open db connection");
        }
        else
        {
            NSString  * query = @"SELECT key,value FROM ItemTable";

            rc =sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt, NULL);


            if (rc == SQLITE_OK)
            {
                while(sqlite3_step(stmt) == SQLITE_ROW )
                {
                    // Get key text
                    const char *key = (const char *)sqlite3_column_text(stmt, 0);
                    NSString *keyString =[[NSString alloc] initWithUTF8String:key];
                    //NSLog(keyString);


                    // Get value as NSDictionary
                    const void *bytes = sqlite3_column_blob(stmt, 1);
                    int length = sqlite3_column_bytes(stmt, 1);
                    NSData *myData = [[NSData alloc] initWithBytes:bytes length:length];
                    NSError* error;
                    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:myData
                                                                         options:kNilOptions
                                                                           error:&error];
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
                    NSString* jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];

                    if([jsonStringMaster length] != 0) {
                        jsonStringMaster = [jsonStringMaster stringByAppendingString:@","];
                    }
                    NSString* jsonStringWithKey = [NSString stringWithFormat:@"\"%@\":%@", keyString,jsonString];
                    jsonStringMaster = [jsonStringMaster stringByAppendingString:jsonStringWithKey];
                    //NSLog(jsonStringMaster);
                }
                sqlite3_finalize(stmt);
            }
            else
            {
                NSLog(@"Failed to prepare statement with rc:%d",rc);
            }
            sqlite3_close(db);
        }
        jsonStringMaster = [jsonStringMaster stringByAppendingString:@"}"];
        jsonStringMaster = [@"{" stringByAppendingString:jsonStringMaster];
        callback(@[jsonStringMaster]);
    }
}

@end