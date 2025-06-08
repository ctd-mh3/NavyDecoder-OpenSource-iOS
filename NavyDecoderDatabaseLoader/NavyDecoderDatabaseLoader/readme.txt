See http://www.raywenderlich.com/12170/core-data-tutorial-how-to-preloadimport-existing-data-updated on process to generate core data from json input.
- Now at https://www.kodeco.com/2935-core-data-on-ios-5-tutorial-how-to-preload-and-import-existing-data

11DEC2022: Now XCode does not show Products so one must use "Product > Show Build Folder in Finder"
- https://stackoverflow.com/questions/70635415/xcode-13-missing-products-folder-when-creating-a-framework
- https://developer.apple.com/forums/thread/691136

Now that this project is setup, here are the steps needed to update the iOS Navy Decoder Core Data:
- Run “perl convertSqlScriptsToJson.pl” in Android app's database directory
- Copy resulting new DecoderData.json to this XCode project
- TO ENSURE NO DUPS:
   *  Right click on the NavyDecoderDatabaseLoader product in "Products' list in XCode and select "Show in Finder"
   *  Delete NavyDecoderDatabaseLoader.sqlite file
- Run(Execute) this project
- Right click on the NavyDecoderDatabaseLoader product in "Products' list in XCode and select "Show in Finder"
- Copy the NavyDecoderDatabaseLoader.sqlite file in the Finder window that opens
- Open NavyDecoder project in XCode
- Right click on the DecoderData.sqlite file and select "Show in Finder"
- Paste the NavyDecoderDatabaseLoader.sqlite into the Finder folder (from NavyDecoder project) that contains DecoderData.sqlite
- Delete the DecoderData.sqlite file and rename the NavyDecoderDatabaseLoader.sqlite to DecoderData.sqlite

