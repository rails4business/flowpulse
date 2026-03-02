module Taxbranches
  class ActivitiesController < ApplicationController
    before_action :set_taxbranch
    before_action :set_lead

    def new
      if @taxbranch.questionnaire_source_path.present? && @taxbranch.post.present?
        redirect_to post_path(@taxbranch.post)
        return
      end

      if @taxbranch.post.present?
        redirect_to post_path(@taxbranch.post)
        return
      end

      @activity = build_activity
    end

    def create
      @activity = build_activity(activity_params)
      @activity.payload = normalized_payload(@activity.payload)

      if @activity.save
        redirect_to dashboard_home_path(tab: "academy"), notice: "Attivita registrata."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_taxbranch
      @taxbranch = Taxbranch.find(params[:taxbranch_id] || params[:id])
    end

    def set_lead
      @lead = Current.user&.lead
      return if @lead.present?

      redirect_to new_session_path, alert: "Devi essere autenticato."
    end

    def build_activity(attrs = {})
      @lead.activities.new(
        {
          domain: Current.domain,
          taxbranch: @taxbranch,
          kind: "step_completed",
          status: "recorded",
          occurred_at: Time.current,
          source: "dashboard_home",
          source_ref: @taxbranch.slug
        }.merge(attrs)
      )
    end

    def activity_params
      params.fetch(:activity, {}).permit(:kind, :status, :occurred_at, :source, :source_ref, :score_total, :score_max, :level_code, payload: {})
    end

    def normalized_payload(value)
      return {} unless value.is_a?(Hash)

      value.compact_blank
    end
  end
end
