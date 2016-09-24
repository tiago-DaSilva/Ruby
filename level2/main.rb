require "json"
require "date"


file = File.read('data.json')

data = JSON.parse(file)

result = {"rentals" => []}
i = 0
data['rentals'].each do |elements|
	car_id = elements['car_id'].to_i
	nb_days = (Date.parse(elements['end_date']) - Date.parse(elements['start_date']) + 1).to_i
	price_per_day = data["cars"].select {|field| field['id'] == car_id}.first['price_per_day']
	price_per_km = data["cars"].select {|field| field['id'] == car_id}.first['price_per_km']
	if (nb_days > 1 && nb_days < 4)
		promo = (price_per_day * 10) / 100
	elsif (nb_days > 4 && nb_days < 10)
		promo = (price_per_day * 30) / 100
	elsif nb_days > 10
		promo = (price_per_day * 50) / 100
	else
		promo = 0
	end
	price = nb_days * price_per_day
	price += elements['distance'] * price_per_km
	price -= promo
	result['rentals'][i] = {"id" => elements['id'], "price" => price}
	i += 1
end
File.open("output.json","w") do |file|
  file.write(JSON.pretty_generate(result))
end
