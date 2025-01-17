class ToolsController < ApplicationController
  include Collection
  skip_before_action :set_owned!, :set_ids!, :set_dates!

  def gemstones
    @collectables = Source.where('text like ?', '%Bicolor Gemstone%')
      .each_with_object(Hash.new { |h, k| h[k] = [] }) do |source, h|
        h[source.collectable_type.downcase.pluralize.to_sym] << source.collectable_id
      end

    @collectables.each do |type, ids|
      model = type.to_s.classify.constantize
      @collectables[type] = model.where(id: ids).include_sources
    end

    @collectables[:orchestrions] = Orchestrion.where('details like ?', '%Bicolor Gemstone%')

    if @character.present?
      @owned_ids = @collectables.keys.each_with_object({}) do |type, h|
        h[type] = @character.send("#{type.to_s.downcase.singularize}_ids")
      end
    end
  end

  def materiel
    @containers = (3..4).each_with_object({}) do |number, h|
      h[number] = {
        mounts: Mount.materiel_container(number).ordered,
        minions: Minion.materiel_container(number).ordered
      }
    end

    if @character.present?
      @owned_ids = {
        mounts: @character.mount_ids,
        minions: @character.minion_ids
      }
    end
  end

  private
  def verify_character_selected!
    unless @character.present?
      flash[:error] = t('alerts.character_not_selected')
      redirect_to root_path
    end
  end
end
