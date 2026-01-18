package com.example.wallpaper_app

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "year_wallpaper_channel"
    }

    private lateinit var prefs: SharedPreferences

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        prefs = getSharedPreferences(
            YearWallpaperService.PREFS_NAME,
            Context.MODE_PRIVATE
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveColors" -> {
                        handleSaveColors(call.arguments, result)
                    }
                    "saveQuote" -> {
                        handleSaveQuote(call.arguments, result)
                    }
                    "saveCustomQuote" -> {
                        handleSaveCustomQuote(call.arguments, result)
                    }
                    "clearCustomQuote" -> {
                        handleClearCustomQuote(result)
                    }
                    "getCustomQuote" -> {
                        handleGetCustomQuote(result)
                    }
                    "openWallpaperChooser" -> {
                        handleOpenWallpaperChooser(result)
                    }
                    "getColors" -> {
                        handleGetColors(result)
                    }
                    "getQuote" -> {
                        handleGetQuote(result)
                    }
                    "saveColumnCount" -> {
                        handleSaveColumnCount(call.arguments, result)
                    }
                    "getColumnCount" -> {
                        handleGetColumnCount(result)
                    }
                    "saveMargins" -> {
                        handleSaveMargins(call.arguments, result)
                    }
                    "getMargins" -> {
                        handleGetMargins(result)
                    }
                    "saveBackgroundSettings" -> {
                        handleSaveBackgroundSettings(call.arguments, result)
                    }
                    "getBackgroundSettings" -> {
                        handleGetBackgroundSettings(result)
                    }
                    "refreshWallpaper" -> {
                        handleRefreshWallpaper(result)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun handleSaveColors(arguments: Any?, result: MethodChannel.Result) {
        try {
            if (arguments !is Map<*, *>) {
                result.error("INVALID_ARGUMENT", "Expected a Map with color values", null)
                return
            }

            val pastColor = (arguments["pastColor"] as? Number)?.toInt()
            val currentColor = (arguments["currentColor"] as? Number)?.toInt()
            val emptyColor = (arguments["emptyColor"] as? Number)?.toInt()

            if (pastColor == null || currentColor == null || emptyColor == null) {
                result.error(
                    "INVALID_ARGUMENT",
                    "Missing required color values (pastColor, currentColor, emptyColor)",
                    null
                )
                return
            }

            prefs.edit().apply {
                putInt(YearWallpaperService.KEY_PAST_COLOR, pastColor)
                putInt(YearWallpaperService.KEY_CURRENT_COLOR, currentColor)
                putInt(YearWallpaperService.KEY_EMPTY_COLOR, emptyColor)
                apply()
            }

            result.success(true)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", "Failed to save colors: ${e.message}", null)
        }
    }

    private fun handleSaveQuote(arguments: Any?, result: MethodChannel.Result) {
        try {
            val quote = arguments as? String
            if (quote == null) {
                result.error("INVALID_ARGUMENT", "Expected a String for quote", null)
                return
            }

            val trimmedQuote = quote.trim()
            if (trimmedQuote.length > 200) {
                result.error("INVALID_ARGUMENT", "Quote must be 200 characters or less", null)
                return
            }

            prefs.edit().apply {
                putString(YearWallpaperService.KEY_CUSTOM_QUOTE, trimmedQuote)
                putLong(YearWallpaperService.KEY_CUSTOM_QUOTE_END_DATE, 0L)
                apply()
            }

            result.success(true)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", "Failed to save quote: ${e.message}", null)
        }
    }

    private fun handleOpenWallpaperChooser(result: MethodChannel.Result) {
        try {
            val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).apply {
                putExtra(
                    WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                    ComponentName(
                        this@MainActivity,
                        YearWallpaperService::class.java
                    )
                )
            }

            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                result.success(true)
            } else {
                val fallbackIntent = Intent(WallpaperManager.ACTION_LIVE_WALLPAPER_CHOOSER)
                if (fallbackIntent.resolveActivity(packageManager) != null) {
                    startActivity(fallbackIntent)
                    result.success(true)
                } else {
                    result.error(
                        "UNAVAILABLE",
                        "Live wallpaper chooser is not available on this device",
                        null
                    )
                }
            }
        } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Failed to open wallpaper chooser: ${e.message}", null)
        }
    }

    private fun handleGetColors(result: MethodChannel.Result) {
        try {
            val colors = mapOf(
                "pastColor" to prefs.getInt(
                    YearWallpaperService.KEY_PAST_COLOR,
                    YearWallpaperService.DEFAULT_PAST_COLOR
                ),
                "currentColor" to prefs.getInt(
                    YearWallpaperService.KEY_CURRENT_COLOR,
                    YearWallpaperService.DEFAULT_CURRENT_COLOR
                ),
                "emptyColor" to prefs.getInt(
                    YearWallpaperService.KEY_EMPTY_COLOR,
                    YearWallpaperService.DEFAULT_EMPTY_COLOR
                )
            )
            result.success(colors)
        } catch (e: Exception) {
            result.error("READ_ERROR", "Failed to read colors: ${e.message}", null)
        }
    }

    private fun handleGetQuote(result: MethodChannel.Result) {
        try {
            val quote = prefs.getString(
                YearWallpaperService.KEY_CUSTOM_QUOTE,
                ""
            )
            result.success(quote)
        } catch (e: Exception) {
            result.error("READ_ERROR", "Failed to read quote: ${e.message}", null)
        }
    }

    private fun handleSaveCustomQuote(arguments: Any?, result: MethodChannel.Result) {
        try {
            if (arguments !is Map<*, *>) {
                result.error("INVALID_ARGUMENT", "Expected a Map with quote and days", null)
                return
            }

            val quote = arguments["quote"] as? String
            val days = (arguments["days"] as? Number)?.toInt() ?: 0

            if (quote == null || quote.trim().isEmpty()) {
                result.error("INVALID_ARGUMENT", "Quote cannot be empty", null)
                return
            }

            val trimmedQuote = quote.trim()
            if (trimmedQuote.length > 200) {
                result.error("INVALID_ARGUMENT", "Quote must be 200 characters or less", null)
                return
            }

            val endDate = if (days > 0) {
                val calendar = Calendar.getInstance()
                calendar.add(Calendar.DAY_OF_YEAR, days)
                calendar.set(Calendar.HOUR_OF_DAY, 23)
                calendar.set(Calendar.MINUTE, 59)
                calendar.set(Calendar.SECOND, 59)
                calendar.timeInMillis
            } else {
                0L
            }

            prefs.edit().apply {
                putString(YearWallpaperService.KEY_CUSTOM_QUOTE, trimmedQuote)
                putLong(YearWallpaperService.KEY_CUSTOM_QUOTE_END_DATE, endDate)
                apply()
            }

            result.success(true)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", "Failed to save custom quote: ${e.message}", null)
        }
    }

    private fun handleClearCustomQuote(result: MethodChannel.Result) {
        try {
            prefs.edit().apply {
                remove(YearWallpaperService.KEY_CUSTOM_QUOTE)
                remove(YearWallpaperService.KEY_CUSTOM_QUOTE_END_DATE)
                apply()
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("CLEAR_ERROR", "Failed to clear custom quote: ${e.message}", null)
        }
    }

    private fun handleGetCustomQuote(result: MethodChannel.Result) {
        try {
            val quote = prefs.getString(YearWallpaperService.KEY_CUSTOM_QUOTE, "") ?: ""
            val endDate = prefs.getLong(YearWallpaperService.KEY_CUSTOM_QUOTE_END_DATE, 0L)
            
            val remainingDays = if (endDate > 0) {
                val currentTime = System.currentTimeMillis()
                if (currentTime > endDate) {
                    0
                } else {
                    val diff = endDate - currentTime
                    (diff / (1000 * 60 * 60 * 24)).toInt() + 1
                }
            } else {
                -1
            }

            val customQuoteInfo = mapOf(
                "quote" to quote,
                "remainingDays" to remainingDays,
                "isPermanent" to (endDate == 0L && quote.isNotEmpty())
            )
            result.success(customQuoteInfo)
        } catch (e: Exception) {
            result.error("READ_ERROR", "Failed to read custom quote: ${e.message}", null)
        }
    }

    private fun handleSaveColumnCount(arguments: Any?, result: MethodChannel.Result) {
        try {
            val columnCount = (arguments as? Number)?.toInt()
            if (columnCount == null) {
                result.error("INVALID_ARGUMENT", "Expected an integer for column count", null)
                return
            }
            if (columnCount < YearWallpaperService.MIN_COLUMN_COUNT || 
                columnCount > YearWallpaperService.MAX_COLUMN_COUNT) {
                result.error(
                    "INVALID_ARGUMENT",
                    "Column count must be between ${YearWallpaperService.MIN_COLUMN_COUNT} and ${YearWallpaperService.MAX_COLUMN_COUNT}",
                    null
                )
                return
            }

            prefs.edit().apply {
                putInt(YearWallpaperService.KEY_COLUMN_COUNT, columnCount)
                apply()
            }

            result.success(true)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", "Failed to save column count: ${e.message}", null)
        }
    }

    private fun handleGetColumnCount(result: MethodChannel.Result) {
        try {
            val columnCount = prefs.getInt(
                YearWallpaperService.KEY_COLUMN_COUNT,
                YearWallpaperService.DEFAULT_COLUMN_COUNT
            )
            result.success(columnCount)
        } catch (e: Exception) {
            result.error("READ_ERROR", "Failed to read column count: ${e.message}", null)
        }
    }

    private fun handleSaveMargins(arguments: Any?, result: MethodChannel.Result) {
        try {
            if (arguments !is Map<*, *>) {
                result.error("INVALID_ARGUMENT", "Expected a Map with margin values", null)
                return
            }

            val topMargin = (arguments["topMargin"] as? Number)?.toFloat() 
                ?: YearWallpaperService.DEFAULT_TOP_MARGIN
            val bottomMargin = (arguments["bottomMargin"] as? Number)?.toFloat() 
                ?: YearWallpaperService.DEFAULT_BOTTOM_MARGIN

            prefs.edit().apply {
                putFloat(YearWallpaperService.KEY_TOP_MARGIN, topMargin)
                putFloat(YearWallpaperService.KEY_BOTTOM_MARGIN, bottomMargin)
                apply()
            }

            result.success(true)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", "Failed to save margins: ${e.message}", null)
        }
    }

    private fun handleGetMargins(result: MethodChannel.Result) {
        try {
            val margins = mapOf(
                "topMargin" to prefs.getFloat(
                    YearWallpaperService.KEY_TOP_MARGIN,
                    YearWallpaperService.DEFAULT_TOP_MARGIN
                ),
                "bottomMargin" to prefs.getFloat(
                    YearWallpaperService.KEY_BOTTOM_MARGIN,
                    YearWallpaperService.DEFAULT_BOTTOM_MARGIN
                )
            )
            result.success(margins)
        } catch (e: Exception) {
            result.error("READ_ERROR", "Failed to read margins: ${e.message}", null)
        }
    }

    private fun handleSaveBackgroundSettings(arguments: Any?, result: MethodChannel.Result) {
        try {
            if (arguments !is Map<*, *>) {
                result.error("INVALID_ARGUMENT", "Expected a Map with background settings", null)
                return
            }

            val type = (arguments["type"] as? Number)?.toInt() ?: 0
            val solidColor = (arguments["solidColor"] as? Number)?.toInt() ?: android.graphics.Color.BLACK
            val gradientColors = (arguments["gradientColors"] as? List<*>)
                ?.mapNotNull { (it as? Number)?.toInt() }
                ?: listOf(android.graphics.Color.BLACK, android.graphics.Color.MAGENTA)
            val gradientAngle = (arguments["gradientAngle"] as? Number)?.toFloat() ?: 0f
            val imagePath = arguments["imagePath"] as? String ?: ""

            prefs.edit().apply {
                putInt(YearWallpaperService.KEY_BG_TYPE, type)
                putInt(YearWallpaperService.KEY_BG_SOLID_COLOR, solidColor)
                putString(YearWallpaperService.KEY_BG_GRADIENT_COLORS, gradientColors.joinToString(","))
                putFloat(YearWallpaperService.KEY_BG_GRADIENT_ANGLE, gradientAngle)
                putString(YearWallpaperService.KEY_BG_IMAGE_PATH, imagePath)
                apply()
            }

            result.success(true)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", "Failed to save background settings: ${e.message}", null)
        }
    }

    private fun handleGetBackgroundSettings(result: MethodChannel.Result) {
        try {
            val colorsStr = prefs.getString(YearWallpaperService.KEY_BG_GRADIENT_COLORS, "-16777216,-8388480") 
                ?: "-16777216,-8388480"
            val colors = colorsStr.split(",").map { it.toInt() }

            val settings = mapOf(
                "type" to prefs.getInt(YearWallpaperService.KEY_BG_TYPE, 0),
                "solidColor" to prefs.getInt(YearWallpaperService.KEY_BG_SOLID_COLOR, android.graphics.Color.BLACK),
                "gradientColors" to colors,
                "gradientAngle" to prefs.getFloat(YearWallpaperService.KEY_BG_GRADIENT_ANGLE, 0f),
                "imagePath" to (prefs.getString(YearWallpaperService.KEY_BG_IMAGE_PATH, "") ?: "")
            )
            result.success(settings)
        } catch (e: Exception) {
            result.error("READ_ERROR", "Failed to read background settings: ${e.message}", null)
        }
    }

    private fun handleRefreshWallpaper(result: MethodChannel.Result) {
        try {
            prefs.edit().apply {
                putLong(YearWallpaperService.KEY_LAST_UPDATE, System.currentTimeMillis())
                apply()
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("REFRESH_ERROR", "Failed to refresh wallpaper: ${e.message}", null)
        }
    }
}
