package com.aliyun.aliinteraction.uikit.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.alivc.auicommon.common.base.util.Utils;
import com.aliyun.aliinteraction.uikit.R;
import com.aliyun.aliinteraction.uikit.uibase.util.ViewUtil;

import java.util.List;

public class SceneChooserAdapter extends RecyclerView.Adapter<SceneChooserAdapter.VH> {
    private List<SceneChooserBean> data;

    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
        View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_scene, viewGroup, false);
        return new VH(view);
    }

    @Override
    public void onBindViewHolder(@NonNull final VH vh, final int i) {
        final SceneChooserBean bean = data != null ? data.get(i) : null;
        if (bean == null) {
            return;
        }

        vh.itemIcon.setImageResource(bean.iconId);
        vh.itemName.setText(bean.nameId);
        ViewUtil.bindClickActionWithClickCheck(vh.itemView, new Runnable() {
            @Override
            public void run() {
                Utils.callSuccess(bean.clickResponseAction, vh.getAdapterPosition());
            }
        });
    }

    @Override
    public int getItemCount() {
        return data != null ? data.size() : 0;
    }

    public <C extends List<SceneChooserBean>> void setData(C data) {
        this.data = data;
    }

    public static class VH extends RecyclerView.ViewHolder {
        public ImageView itemIcon;
        public TextView itemName;

        public VH(@NonNull View itemView) {
            super(itemView);
            itemIcon = itemView.findViewById(R.id.itemIcon);
            itemName = itemView.findViewById(R.id.itemName);
        }
    }
}

