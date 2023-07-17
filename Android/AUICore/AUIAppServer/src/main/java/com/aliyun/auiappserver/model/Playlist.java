package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.Serializable;

@JsonIgnoreProperties(ignoreUnknown = true)
public class Playlist implements Serializable {
    public int bit_depth;
    public String bit_rate;
    public String creation_time;
    public String definition;
    public String duration;
    public int encrypt;
    public String encrypt_type;
    public String format;
    public String fps;
    public String hdr_type;
    public int height;
    public String play_url;
    public long size;
    public String status;
    public String stream_type;
    public String watermark_id;
    public int width;
}
