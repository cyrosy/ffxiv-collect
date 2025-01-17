namespace :ownership do
  desc 'Cache collectable ownership'
  task cache: :environment do
    achievement_characters = Character.visible.recent.with_public_achievements
    mount_minion_characters = Character.visible.recent
    manual_collection_characters = Character.visible.recent.verified

    [Orchestrion, Emote, Barding, Hairstyle, Armoire, Spell, Relic, Fashion, Record].each do |model|
      cache_ownership(model, manual_collection_characters)
    end

    [Mount, Minion].each do |model|
      cache_ownership(model, mount_minion_characters)
    end

    cache_ownership(Achievement, achievement_characters)

    puts
  end

  def cache_ownership(model, characters)
    puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')}] Caching #{model}s"
    key = model.to_s.downcase.pluralize
    relation = "Character#{model}".constantize
    current = Redis.current.hgetall("#{key}-count")
    total = characters.where("#{key}_count > 0").size

    puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')}] Setting percentages"
    ownership = relation.where(character: characters).group("#{key.singularize}_id").count
      .each_with_object({}) do |(id, owners), h|
      percentage = ((owners / total.to_f) * 100).to_s[0..2].sub(/\.\Z/, '').sub(/0\.0/, '0')
      h[id] = { count: owners, percentage: "#{percentage}%" }
    end

    puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')}] Collecting updated models"
    updated = ownership.filter_map do |id, data|
      id unless data[:count].to_s == current[id.to_s]
    end

    # Touch collectables with updated ownership to expire cached data
    puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')}] Touching models"
    model.where(id: updated).update_all(updated_at: Time.now)

    Redis.current.hmset(key, ownership_to_set(ownership, :percentage))
    Redis.current.hmset("#{key}-count", ownership_to_set(ownership, :count))
  end
end

private
def ownership_to_set(ownership, key)
  ownership.map { |id, data| [id, data[key]] }.flatten
end
