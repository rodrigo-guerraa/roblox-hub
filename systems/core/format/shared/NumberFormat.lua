local NumberFormat = {}

NumberFormat.CURRENCY = "$"

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

-- 999 -> "999", 1450 -> "1.4K", 25300000 -> "25.3M"; small fractions keep one decimal (37.5)
function NumberFormat.Short(n)
	n = tonumber(n) or 0
	if n ~= n then
		n = 0
	end
	local sign = n < 0 and "-" or ""
	n = math.abs(n)
	if n < 1000 then
		if n < 100 and n ~= math.floor(n) then
			return sign .. string.format("%.1f", math.floor(n * 10) / 10)
		end
		return sign .. tostring(math.floor(n))
	end
	local index = 1
	while n >= 1000 and index < #SUFFIXES do
		n /= 1000
		index += 1
	end
	local text
	if n >= 100 then
		text = tostring(math.floor(n))
	else
		text = string.format("%.1f", math.floor(n * 10) / 10):gsub("%.0$", "")
	end
	return sign .. text .. SUFFIXES[index]
end

function NumberFormat.Money(n)
	return NumberFormat.CURRENCY .. NumberFormat.Short(n)
end

function NumberFormat.Rate(n)
	return NumberFormat.CURRENCY .. NumberFormat.Short(n) .. "/s"
end

return NumberFormat
