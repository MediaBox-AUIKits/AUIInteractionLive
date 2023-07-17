package com.aliyun.aliinteraction.uikit.uibase.helper;

import android.animation.Animator;
import android.animation.ValueAnimator;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;

import com.aliyun.aliinteraction.uikit.uibase.listener.SimpleAnimatorListener;

/**
 * @author puke
 * @version 2022/11/16
 */
public class ExpandShrinkAnimationHelper {

    private static final int ANIMATION_DURATION = 200;

    public static void doExpandAnimation(final View view) {
        final int originWidth;
        if (view.getVisibility() == View.VISIBLE
                || (originWidth = view.getLayoutParams().width) == 0) {
            return;
        }

        ValueAnimator animator = ValueAnimator.ofFloat(0, 1)
                .setDuration(ANIMATION_DURATION);
        animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                float progress = (float) animation.getAnimatedValue();
                setViewWidth(view, (int) (originWidth * progress));
            }
        });
        animator.addListener(new SimpleAnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
                view.setVisibility(View.VISIBLE);
                setViewWidth(view, 0);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                view.setVisibility(View.VISIBLE);
                setViewWidth(view, ViewGroup.LayoutParams.WRAP_CONTENT);
            }
        });
        animator.start();
    }

    public static void doShrinkAnimation(final View view, @Nullable final Runnable endListener) {
        if (view.getVisibility() == View.GONE) {
            if (endListener != null) {
                endListener.run();
            }
            return;
        }

        final int originWidth = view.getWidth();
        ValueAnimator animator = ValueAnimator.ofFloat(1, 0)
                .setDuration(ANIMATION_DURATION);
        animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                float progress = (float) animation.getAnimatedValue();
                setViewWidth(view, (int) (originWidth * progress));
            }
        });
        animator.addListener(new SimpleAnimatorListener() {
            @Override
            public void onAnimationEnd(Animator animation) {
                view.setVisibility(View.GONE);
                setViewWidth(view, ViewGroup.LayoutParams.WRAP_CONTENT);
                if (endListener != null) {
                    endListener.run();
                }
            }
        });
        animator.start();
    }

    private static void setViewWidth(View view, int width) {
        ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
        if (layoutParams != null) {
            layoutParams.width = width;
            view.setLayoutParams(layoutParams);
        }
    }
}
