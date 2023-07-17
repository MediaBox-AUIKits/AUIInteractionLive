package com.aliyun.auipusher;

import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

/**
 * @author puke
 * @version 2022/11/22
 */
public class AnchorPreviewHolder {

    private View previewView;
    private ViewGroup previewViewContainer;

    public void returnBigContainer() {
        if (previewViewContainer != null && previewView != null) {
            ViewParent parent = previewView.getParent();
            if (parent != previewViewContainer) {
                if (parent != null) {
                    ((ViewGroup) parent).removeView(previewView);
                }
                previewViewContainer.addView(previewView);
            }
        }
    }

    public View getPreviewView() {
        return previewView;
    }

    public void setPreviewView(View previewView) {
        this.previewView = previewView;
        this.previewViewContainer = (ViewGroup) previewView.getParent();
    }
}
