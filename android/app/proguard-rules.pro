# google_mlkit_text_recognition references optional script recognizer classes
# from the Flutter plugin switch. This app only initializes the Latin recognizer,
# so these optional script-specific classes may be absent in release builds.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
