module ArrayUtils

function enforceSize(values, desiredLength, fillUpValue = 0)
    currentLength = length(values)
    if currentLength == desiredLength
        return values
    end
    if currentLength < desiredLength
        return fillUpArray(values, desiredLength, fillUpValue)
    end
    
    return pickLastItems(values, desiredLength)
end

function pickLastItems(values, count)
    lastIndex = length(values)
    firstIndex = lastIndex > count ? lastIndex - count + 1 : 1
    return values[firstIndex:lastIndex]
end

function fillUpArray(values, desiredLength, fillUpValue = 0)
    currentLength = length(values)
    diff = desiredLength - currentLength
    if diff <= 0
        return values
    end
    fillingValues = fill(fillUpValue, diff)
    newValues = [fillingValues..., values...]
    return newValues
end
end