local localVoiceRange = 2
local previousVoiceRange = 2
local interpolatedVoiceRange = 2
local transitioning = false
local baseTransitionTime = 1500 -- Base transition time in milliseconds
local transitionTime = baseTransitionTime
local updateInterval = 100 -- Update interval in milliseconds

local function startTransition(newVoiceRange)
    if transitioning then
        -- Extend the transition time if a new event is triggered during an ongoing transition
        transitionTime = transitionTime + (baseTransitionTime / 2) -- extend by half of the base time
    else
        -- Start a new transition
        transitioning = true
        transitionTime = baseTransitionTime
    end

    previousVoiceRange = interpolatedVoiceRange
    localVoiceRange = newVoiceRange

    Citizen.CreateThread(function()
        local startTime = GetGameTimer()

        while transitioning do
            Citizen.Wait(0)
            local elapsedTime = GetGameTimer() - startTime

            -- Recalculate the step size based on current ranges
            local step = (localVoiceRange - interpolatedVoiceRange) * updateInterval / transitionTime

            if elapsedTime < transitionTime then
                interpolatedVoiceRange = interpolatedVoiceRange + step
                if step > 0 then -- Increasing
                    interpolatedVoiceRange = math.min(interpolatedVoiceRange, localVoiceRange)
                else -- Decreasing
                    interpolatedVoiceRange = math.max(interpolatedVoiceRange, localVoiceRange)
                end
            else
                interpolatedVoiceRange = localVoiceRange
                transitioning = false
                transitionTime = baseTransitionTime -- Reset the transition time
            end

            -- Draw the marker with the current interpolatedVoiceRange
            local playerPedPosition = GetEntityCoords(PlayerPedId(), true)
            DrawMarker(1, playerPedPosition.x, playerPedPosition.y, playerPedPosition.z - 1.0,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    interpolatedVoiceRange * 2, interpolatedVoiceRange * 2, 1.0,
                    12, 171, 182, 166,
                    false, true, 1, nil, nil, false)
        end
    end)
end

AddEventHandler('SaltyChat_VoiceRangeChanged', function(voiceRange)
    startTransition(voiceRange)
end)
