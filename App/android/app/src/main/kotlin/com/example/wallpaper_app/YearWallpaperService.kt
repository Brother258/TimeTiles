package com.example.wallpaper_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.*
import android.os.Handler
import android.os.Looper
import android.service.wallpaper.WallpaperService
import android.text.TextPaint
import android.text.TextUtils
import android.view.SurfaceHolder
import java.io.File
import java.util.Calendar
import kotlin.math.cos
import kotlin.math.sin

class YearWallpaperService : WallpaperService() {

    companion object {
        const val PREFS_NAME = "year_wallpaper_prefs"
        const val KEY_PAST_COLOR = "past_color"
        const val KEY_CURRENT_COLOR = "current_color"
        const val KEY_EMPTY_COLOR = "empty_color"
        const val KEY_CUSTOM_QUOTE = "custom_quote"
        const val KEY_CUSTOM_QUOTE_END_DATE = "custom_quote_end_date"
        const val KEY_COLUMN_COUNT = "column_count"
        const val KEY_TOP_MARGIN = "top_margin"
        const val KEY_BOTTOM_MARGIN = "bottom_margin"
        const val KEY_BG_TYPE = "bg_type"
        const val KEY_BG_SOLID_COLOR = "bg_solid_color"
        const val KEY_BG_GRADIENT_COLORS = "bg_gradient_colors"
        const val KEY_BG_GRADIENT_ANGLE = "bg_gradient_angle"
        const val KEY_BG_IMAGE_PATH = "bg_image_path"
        const val KEY_LAST_UPDATE = "last_update"
        const val ACTION_REDRAW = "com.example.wallpaper_app.ACTION_REDRAW"

        const val DEFAULT_PAST_COLOR = 0xFF4CAF50.toInt()
        const val DEFAULT_CURRENT_COLOR = 0xFFFF9800.toInt()
        const val DEFAULT_EMPTY_COLOR = 0xFF424242.toInt()
        const val DEFAULT_COLUMN_COUNT = 7
        const val DEFAULT_TOP_MARGIN = 20.0f
        const val DEFAULT_BOTTOM_MARGIN = 20.0f

        const val BG_TYPE_SOLID = 0
        const val BG_TYPE_LINEAR_GRADIENT = 1
        const val BG_TYPE_RADIAL_GRADIENT = 2
        const val BG_TYPE_SWEEP_GRADIENT = 3
        const val BG_TYPE_IMAGE = 4

        const val MIN_COLUMN_COUNT = 4
        const val MAX_COLUMN_COUNT = 20
        const val BLOCK_SPACING = 4f

        val DAILY_QUOTES = listOf(
            "Make every day count",
            "Progress, not perfection",
            "Small steps, big results",
            "Today is your day",
            "Keep pushing forward",
            "Believe in yourself",
            "Stay focused, stay strong",
            "Dream big, act now",
            "You are capable",
            "Embrace the journey",
            "One day at a time",
            "Your time is now",
            "Make it happen",
            "Stay positive always",
            "Never give up",
            "Rise and shine",
            "Be the change",
            "Chase your dreams",
            "Stay hungry, stay foolish",
            "Life is beautiful",
            "Create your future",
            "Be unstoppable",
            "Think big thoughts",
            "Act with purpose",
            "Live with intention",
            "Grow through challenges",
            "Shine your light",
            "Trust the process",
            "Keep learning daily",
            "Spread kindness everywhere",
            "Be brave today",
            "Find your passion",
            "Live fully now",
            "Success takes time",
            "Stay committed always",
            "You matter greatly",
            "Believe and achieve",
            "Make today amazing",
            "Start where you are",
            "Use what you have",
            "Do what you can",
            "Every day matters",
            "Progress is progress",
            "Stay true to yourself",
            "Embrace new beginnings",
            "You are enough",
            "Keep moving forward",
            "Today defines tomorrow",
            "Create positive habits",
            "Be your best self",
            "Live without limits",
            "Seize every moment",
            "Make memories daily",
            "Stay curious always",
            "Learn from yesterday",
            "Live for today",
            "Hope for tomorrow",
            "Action beats fear",
            "Dreams need deadlines",
            "Focus on growth",
            "Be grateful daily",
            "Celebrate small wins",
            "Stay determined always",
            "Your journey matters",
            "Inspire others daily",
            "Be the light",
            "Choose happiness now",
            "Create your story",
            "Live with courage",
            "Trust yourself more",
            "Make waves today",
            "Be extraordinary daily",
            "Own your power",
            "Stay resilient always",
            "Bloom where planted",
            "Rise above doubts",
            "Embrace every challenge",
            "You are limitless",
            "Make a difference",
            "Stay inspired daily",
            "Be bold today",
            "Live your truth",
            "Create magic daily",
            "Stay strong always",
            "Believe in magic",
            "Chase the sunrise",
            "Write your story",
            "Be fearlessly you",
            "Live with passion",
            "Stay humble, hustle hard",
            "Dream without limits",
            "Make it count",
            "Be relentlessly positive",
            "Today is precious",
            "You are powerful",
            "Stay motivated daily",
            "Create your sunshine",
            "Be amazing today",
            "Live beautifully now",
            "Every moment counts"
        )
    }

    override fun onCreateEngine(): Engine {
        return YearWallpaperEngine()
    }

    inner class YearWallpaperEngine : Engine(), SharedPreferences.OnSharedPreferenceChangeListener {

        private val handler = Handler(Looper.getMainLooper())
        private var visible = false
        private lateinit var prefs: SharedPreferences
        private var backgroundBitmap: Bitmap? = null

        private val blockPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        private val textPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textAlign = Paint.Align.CENTER
        }

        override fun onCreate(surfaceHolder: SurfaceHolder?) {
            super.onCreate(surfaceHolder)
            prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.registerOnSharedPreferenceChangeListener(this)
            scheduleMidnightAlarm()
            loadBackgroundImage()
        }

        override fun onDestroy() {
            super.onDestroy()
            prefs.unregisterOnSharedPreferenceChangeListener(this)
            backgroundBitmap?.recycle()
            backgroundBitmap = null
        }

        override fun onSharedPreferenceChanged(sharedPreferences: SharedPreferences?, key: String?) {
            if (key == KEY_BG_IMAGE_PATH) {
                loadBackgroundImage()
            }
            draw()
        }

        private fun loadBackgroundImage() {
            val bgType = prefs.getInt(KEY_BG_TYPE, BG_TYPE_SOLID)
            if (bgType == BG_TYPE_IMAGE) {
                val imagePath = prefs.getString(KEY_BG_IMAGE_PATH, null)
                if (imagePath != null && imagePath.isNotEmpty()) {
                    try {
                        val file = File(imagePath)
                        if (file.exists()) {
                            backgroundBitmap?.recycle()
                            backgroundBitmap = BitmapFactory.decodeFile(imagePath)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            } else {
                backgroundBitmap?.recycle()
                backgroundBitmap = null
            }
        }

        override fun onVisibilityChanged(visible: Boolean) {
            this.visible = visible
            if (visible) {
                draw()
            }
        }

        override fun onSurfaceChanged(
            holder: SurfaceHolder?,
            format: Int,
            width: Int,
            height: Int
        ) {
            super.onSurfaceChanged(holder, format, width, height)
            draw()
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder?) {
            super.onSurfaceDestroyed(holder)
            visible = false
        }

        fun draw() {
            if (!visible) return

            val holder = surfaceHolder
            var canvas: Canvas? = null

            try {
                canvas = holder.lockCanvas()
                if (canvas != null) {
                    drawWallpaper(canvas)
                }
            } finally {
                if (canvas != null) {
                    try {
                        holder.unlockCanvasAndPost(canvas)
                    } catch (e: IllegalArgumentException) {
                    }
                }
            }
        }

        private fun getCurrentQuote(dayOfYear: Int): String {
            val customQuote = prefs.getString(KEY_CUSTOM_QUOTE, null)
            val customQuoteEndDate = prefs.getLong(KEY_CUSTOM_QUOTE_END_DATE, 0L)
            
            if (customQuote != null && customQuote.isNotEmpty()) {
                val currentTime = System.currentTimeMillis()
                if (customQuoteEndDate == 0L || currentTime <= customQuoteEndDate) {
                    return customQuote
                }
                prefs.edit().apply {
                    remove(KEY_CUSTOM_QUOTE)
                    remove(KEY_CUSTOM_QUOTE_END_DATE)
                    apply()
                }
            }
            
            val quoteIndex = (dayOfYear - 1) % DAILY_QUOTES.size
            return DAILY_QUOTES[quoteIndex]
        }

        private fun drawBackground(canvas: Canvas, width: Float, height: Float) {
            val bgType = prefs.getInt(KEY_BG_TYPE, BG_TYPE_SOLID)
            val rect = RectF(0f, 0f, width, height)

            when (bgType) {
                BG_TYPE_SOLID -> {
                    val color = prefs.getInt(KEY_BG_SOLID_COLOR, Color.BLACK)
                    canvas.drawColor(color)
                }
                BG_TYPE_LINEAR_GRADIENT -> {
                    val colorsStr = prefs.getString(KEY_BG_GRADIENT_COLORS, "-16777216,-8388480") ?: "-16777216,-8388480"
                    val colors = colorsStr.split(",").map { it.toInt() }.toIntArray()
                    val angle = prefs.getFloat(KEY_BG_GRADIENT_ANGLE, 0f)
                    
                    val angleRad = Math.toRadians(angle.toDouble())
                    val centerX = width / 2
                    val centerY = height / 2
                    val length = maxOf(width, height)
                    
                    val startX = centerX - (cos(angleRad) * length / 2).toFloat()
                    val startY = centerY - (sin(angleRad) * length / 2).toFloat()
                    val endX = centerX + (cos(angleRad) * length / 2).toFloat()
                    val endY = centerY + (sin(angleRad) * length / 2).toFloat()
                    
                    val gradient = LinearGradient(
                        startX, startY, endX, endY,
                        colors, null, Shader.TileMode.CLAMP
                    )
                    val paint = Paint().apply { shader = gradient }
                    canvas.drawRect(rect, paint)
                }
                BG_TYPE_RADIAL_GRADIENT -> {
                    val colorsStr = prefs.getString(KEY_BG_GRADIENT_COLORS, "-16777216,-8388480") ?: "-16777216,-8388480"
                    val colors = colorsStr.split(",").map { it.toInt() }.toIntArray()
                    
                    val gradient = RadialGradient(
                        width / 2, height / 2, maxOf(width, height) / 2,
                        colors, null, Shader.TileMode.CLAMP
                    )
                    val paint = Paint().apply { shader = gradient }
                    canvas.drawRect(rect, paint)
                }
                BG_TYPE_SWEEP_GRADIENT -> {
                    val colorsStr = prefs.getString(KEY_BG_GRADIENT_COLORS, "-16777216,-8388480") ?: "-16777216,-8388480"
                    val colors = colorsStr.split(",").map { it.toInt() }.toIntArray()
                    
                    val gradient = SweepGradient(width / 2, height / 2, colors, null)
                    val paint = Paint().apply { shader = gradient }
                    canvas.drawRect(rect, paint)
                }
                BG_TYPE_IMAGE -> {
                    backgroundBitmap?.let { bitmap ->
                        val srcRect = Rect(0, 0, bitmap.width, bitmap.height)
                        val dstRect = Rect(0, 0, width.toInt(), height.toInt())
                        canvas.drawBitmap(bitmap, srcRect, dstRect, null)
                    } ?: canvas.drawColor(Color.BLACK)
                }
                else -> canvas.drawColor(Color.BLACK)
            }
        }

        private fun drawWallpaper(canvas: Canvas) {
            val width = canvas.width.toFloat()
            val height = canvas.height.toFloat()

            drawBackground(canvas, width, height)

            val topMarginPercent = prefs.getFloat(KEY_TOP_MARGIN, DEFAULT_TOP_MARGIN)
            val bottomMarginPercent = prefs.getFloat(KEY_BOTTOM_MARGIN, DEFAULT_BOTTOM_MARGIN)

            val topMargin = height * (topMarginPercent / 100f)
            val bottomMargin = height * (bottomMarginPercent / 100f)
            val contentHeight = height - topMargin - bottomMargin
            val horizontalPadding = width * 0.05f

            val calendar = Calendar.getInstance()
            val currentYear = calendar.get(Calendar.YEAR)
            val currentDayOfYear = calendar.get(Calendar.DAY_OF_YEAR)
            val totalDays = getTotalDaysInYear(currentYear)

            val pastColor = prefs.getInt(KEY_PAST_COLOR, DEFAULT_PAST_COLOR)
            val currentColor = prefs.getInt(KEY_CURRENT_COLOR, DEFAULT_CURRENT_COLOR)
            val emptyColor = prefs.getInt(KEY_EMPTY_COLOR, DEFAULT_EMPTY_COLOR)
            val columnCount = prefs.getInt(KEY_COLUMN_COUNT, DEFAULT_COLUMN_COUNT)
            
            val quote = getCurrentQuote(currentDayOfYear)

            val gridAreaHeight = contentHeight * 0.65f
            val textAreaHeight = contentHeight * 0.35f

            val rowCount = kotlin.math.ceil(totalDays.toDouble() / columnCount).toInt()
            val availableWidth = width - (horizontalPadding * 2)

            val blockWidthWithSpacing = availableWidth / columnCount
            val blockHeightWithSpacing = gridAreaHeight / rowCount

            val blockSizeWithSpacing = minOf(blockWidthWithSpacing, blockHeightWithSpacing)
            val blockSize = (blockSizeWithSpacing - BLOCK_SPACING).coerceAtLeast(1f)

            val gridWidth = blockSizeWithSpacing * columnCount
            val gridHeight = blockSizeWithSpacing * rowCount

            val gridStartX = (width - gridWidth) / 2
            val gridStartY = topMargin + (gridAreaHeight - gridHeight) / 2

            for (day in 1..totalDays) {
                val index = day - 1
                val col = index % columnCount
                val row = index / columnCount

                val x = gridStartX + (col * blockSizeWithSpacing)
                val y = gridStartY + (row * blockSizeWithSpacing)

                blockPaint.color = when {
                    day < currentDayOfYear -> pastColor
                    day == currentDayOfYear -> currentColor
                    else -> emptyColor
                }

                canvas.drawRect(
                    x,
                    y,
                    x + blockSize,
                    y + blockSize,
                    blockPaint
                )
            }

            val textStartY = topMargin + gridAreaHeight + (textAreaHeight * 0.15f)
            val passedDays = currentDayOfYear - 1
            val remainingDays = totalDays - currentDayOfYear

            textPaint.textSize = width / 22f
            textPaint.color = Color.WHITE
            canvas.drawText(
                "$currentYear",
                width / 2,
                textStartY,
                textPaint
            )

            textPaint.textSize = width / 28f
            val statsY = textStartY + textPaint.textSize * 1.8f
            canvas.drawText(
                "$passedDays days passed  •  $remainingDays days remaining",
                width / 2,
                statsY,
                textPaint
            )

            val progressPercent = (passedDays.toFloat() / totalDays * 100)
            val progressText = String.format("%.2f%% complete", progressPercent)
            textPaint.textSize = width / 18f
            val progressY = statsY + textPaint.textSize * 1.5f
            canvas.drawText(
                progressText,
                width / 2,
                progressY,
                textPaint
            )

            textPaint.textSize = width / 32f
            textPaint.color = 0xCCFFFFFF.toInt()
            val quoteY = progressY + textPaint.textSize * 2.2f
            val maxQuoteWidth = width - (horizontalPadding * 2)
            val ellipsizedQuote = TextUtils.ellipsize(
                "\"$quote\"",
                textPaint,
                maxQuoteWidth,
                TextUtils.TruncateAt.END
            ).toString()

            canvas.drawText(
                ellipsizedQuote,
                width / 2,
                quoteY,
                textPaint
            )
        }

        private fun isLeapYear(year: Int): Boolean {
            return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        }

        private fun getTotalDaysInYear(year: Int): Int {
            return if (isLeapYear(year)) 366 else 365
        }

        private fun scheduleMidnightAlarm() {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            
            val intent = Intent(applicationContext, MidnightReceiver::class.java).apply {
                action = ACTION_REDRAW
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                applicationContext,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val calendar = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, 1)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            alarmManager.setInexactRepeating(
                AlarmManager.RTC,
                calendar.timeInMillis,
                AlarmManager.INTERVAL_DAY,
                pendingIntent
            )
        }
    }
}

class MidnightReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == YearWallpaperService.ACTION_REDRAW) {
            val prefs = context.getSharedPreferences(
                YearWallpaperService.PREFS_NAME,
                Context.MODE_PRIVATE
            )
            
            prefs.edit().apply {
                putLong(YearWallpaperService.KEY_LAST_UPDATE, System.currentTimeMillis())
                apply()
            }
        }
    }
}
