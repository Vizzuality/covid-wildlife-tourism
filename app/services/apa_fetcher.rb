class ApaFetcher
  include Singleton
  include HTTParty

  base_uri 'infopraiaapi.apambiente.pt'

  class << self
    delegate :water_quality, to: :instance
    delegate :occupation, to: :instance
  end

  def water_quality
    data = self.class.get('/qualidade.json')&.body
    return if data.blank?

    JSON.parse(data)['features'].each do |entry|
      attrs = entry['attributes']
      next if !attrs['data_ultima_classificacao'] || !attrs['codigo_agua_balnear']

      b_config = BeachConfiguration.find_by(water_code: attrs['codigo_agua_balnear'])

      if !b_config
        puts "can't find beach config for #{attrs['codigo_agua_balnear']}"
        next
      end

      last_update = DateTime.strptime(attrs['data_ultima_classificacao'].to_s, '%Q')
      next if b_config.water_quality_updated_at.present? && b_config.water_quality_updated_at > last_update

      b_config.water_quality = attrs['ultima_classificacao']
      b_config.water_quality_updated_at = last_update
      b_config.save
    end
  end

  def occupation
    data = self.class.get('/ocupacao.json')&.body
    return if data.blank?

    JSON.parse(data).each do |entry|
      b_config = BeachConfiguration.find_by(code: entry['code'])
      next unless b_config && entry['state'].present? && entry['hour'].present?

      time = DateTime.strptime(entry['hour'].to_s, '%Q')

      # TODO: need to define how to parse the state
      StatusStoreOwner.create!(
        store_id: b_config.store.id,
        updated_time: time,
        status: entry['state'],
        valid_until: time + 2.hours,
        is_official: true
      )
    end
  end
end
