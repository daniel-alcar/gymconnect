package br.com.gymconnect.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public class ChatCoachResponse {

    @JsonProperty("reply")
    private String reply;

    public ChatCoachResponse() {
    }

    public ChatCoachResponse(String reply) {
        this.reply = reply;
    }

    public String getReply() {
        return reply;
    }

    public void setReply(String reply) {
        this.reply = reply;
    }
}
