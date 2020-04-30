namespace :items do
  desc 'Create generic trackable items'
  task create: :environment do
    PaperTrail.enabled = false

    puts 'Creating generic items'
    count = Item.count

    categories = {
      tools: Item.relic_tool_ids,
      gear: Item.relic_gear_ids,
      deep_dungeon: Item.deep_dungeon_weapon_ids
    }

    categories.each do |name, ids|
      items = XIVAPI_CLIENT.content(name: 'Item', columns: %w(ID Name_* Icon), ids: ids, limit: 1000).map do |item|
        data = { id: item.id }

        %w(en de fr ja).each do |locale|
          data["name_#{locale}"] = sanitize_name(item["name_#{locale}"])
        end

        download_image(data[:id], item.icon, "items/#{name}")

        if existing = Item.find_by(id: item.id)
          data = without_custom(data)
          existing.update!(data) if updated?(existing, data.symbolize_keys)
        else
          Item.create!(data)
        end
      end

      create_spritesheet("items/#{name}")
    end

    puts "Created #{Item.count - count} new items"
  end
end