require "json"
require "date"


file = File.read('data.json')

data = JSON.parse(file)

result = {"rental_modifications" => []}
actor = ['driver', 'owner', 'insurance', 'assistance', 'drivy']
i = 0


data['rental_modifications'].each do |elements|
	rental_id = elements['rental_id'].to_i
	modification = data['rentals'].select {|field| field['id'] == rental_id}.first
	car_id = modification['car_id'].to_i
	modification.each do |modifElem|
		elements.each do |fieldElem|
			if modifElem[0] == fieldElem[0]
				modification[modifElem[0]] = fieldElem[1]
			end
		end
	end
	nb_days = (Date.parse(modification['end_date']) - Date.parse(modification['start_date']) + 1).to_i
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
	price = nb_days * (price_per_day - promo)
	price += modification['distance'] * price_per_km

	commission = (price * 30) / 100
	rest = (commission / 2) - (nb_days * 100)
	if modification['deductible_reduction'] == true
		reduction = nb_days * 4 * 100
	else
		reduction = 0
	end
	result["rental_modifications"][i] = {
		"id" => elements['id'],
		"rental_id" => elements['rental_id'],
		"actions" => []
	}
	x = 0
	actor.each do |actorsName|
		case actorsName
		when 'driver'
			type = "debit"
			amount = price + reduction
		when 'owner'
			type = "credit"
			amount = price - commission
		when 'insurance'
			type = "credit"
			amount = commission / 2
		when 'assistance'
			type = "credit"
			amount = nb_days * 100
		when 'drivy'
			type = "credit"
			amount = rest + reduction
		end
		result["rental_modifications"][i]['actions'][x] = {
			"who" => actorsName,
			"type" => type,
			"amount" => amount
		}
		x += 1
	end
	i += 1
end
File.open("output.json","w") do |file|
  file.write(JSON.pretty_generate(result))
end
