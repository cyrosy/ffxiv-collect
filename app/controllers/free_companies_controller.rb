class FreeCompaniesController < ApplicationController
  before_action :set_free_company
  before_action :set_members, except: :refresh

  def show
  end

  def mounts
    @collection = 'mounts'
    @sprite_key = 'mounts-small'
    @collectables = Mount.joins(sources: :type)
      .where('source_types.name in (?)', %w(Trial Raid))
      .order('source_types.name DESC, mounts.patch ASC')
      .distinct.group_by(&:expansion)

    @owned_ids = CharacterMount.where(character_id: @members)
      .each_with_object(Hash.new { |k, v| k[v] = [] }) do |char, h|
        h[char.character_id] << char.mount_id
      end

    render 'collection'
  end

  def refresh
    if @free_company.in_queue?
      flash[:alert] = t('alerts.free_company_syncing')
    elsif !@free_company.syncable?
      flash[:alert] = t('alerts.free_company_already_refreshed')
    else
      begin
        @free_company.sync_members
        flash[:success] = t('alerts.free_company_refreshed')
      rescue ActiveJob::Uniqueness::JobNotUnique
        flash[:alert] = t('alerts.free_company_syncing')
      end
    end

    redirect_to free_company_path(@free_company)
  end

  private
  def set_free_company
    @free_company = FreeCompany.find(params[:id] || params[:free_company_id])
  end

  def set_members
    @members = @free_company.members.order(:name)
  end
end
