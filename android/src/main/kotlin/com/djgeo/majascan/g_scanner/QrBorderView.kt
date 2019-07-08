package com.djgeo.majascan.g_scanner

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.widget.RelativeLayout

class QrBorderView @JvmOverloads constructor(
        context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : RelativeLayout(context, attrs, defStyleAttr) {

    private val mPaint: Paint = Paint(Paint.ANTI_ALIAS_FLAG)       //for qrcode 四角落外框寬度
    private val mBorderPaint: Paint = Paint(Paint.ANTI_ALIAS_FLAG) //for qrcode 外框寬度
    private var width: Float = 0.toFloat()
    private var height: Float = 0.toFloat()

    init {
        //设置是否使用抗锯齿功能，会消耗较大资源，绘制图形速度会变慢。
        mPaint.isDither = true//设定是否使用图像抖动处理，会使绘制出来的图片颜色更加平滑和饱满，图像更加清晰
        mPaint.color = Color.rgb(255,136,0)
        mPaint.style = Paint.Style.FILL
        mPaint.strokeWidth = 20f

        mBorderPaint.isDither = true
        mBorderPaint.color = Color.rgb(186, 186, 186)
        mBorderPaint.style = Paint.Style.STROKE
        mBorderPaint.strokeWidth = 4f
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        width = w.toFloat()
        height = h.toFloat()
    }

    override fun onDraw(canvas: Canvas?) {
        super.onDraw(canvas)

        //Draw border
        canvas?.drawLine(0f, 0f, width, 0f, mBorderPaint)
        canvas?.drawLine(0f, 0f, 0f, height, mBorderPaint)
        canvas?.drawLine(0f, height, width, height, mBorderPaint)
        canvas?.drawLine(width, 0f, width, height, mBorderPaint)

        val cornerWidth = width / 5 //四角落外框寬度

        //左上
        canvas?.drawLine(0f, 0f, cornerWidth, 0f, mPaint)
        canvas?.drawLine(0f, 0f, 0f, cornerWidth, mPaint)

        //右上
        canvas?.drawLine(width - cornerWidth, 0f, width, 0f, mPaint)
        canvas?.drawLine(width, 0f, width, cornerWidth, mPaint)

        //左下
        canvas?.drawLine(0f, height, cornerWidth, height, mPaint)
        canvas?.drawLine(0f, height - cornerWidth, 0f, height, mPaint)

        //右下
        canvas?.drawLine(width - cornerWidth, height, width, height, mPaint)
        canvas?.drawLine(width, height, width, height - cornerWidth, mPaint)
    }

    fun setQRCornerColor(cornerColor: Int) {
        mPaint.color = cornerColor
    }
}