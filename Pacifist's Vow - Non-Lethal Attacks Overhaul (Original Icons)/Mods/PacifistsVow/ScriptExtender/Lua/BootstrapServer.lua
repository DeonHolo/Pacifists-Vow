local NULL_GUID = "NULL_00000000-0000-0000-0000-000000000000"

local function getPartyMember()
    local partyMembers = Osi.DB_PartyMembers:Get(nil)
    if partyMembers and partyMembers[1] then
        return partyMembers[1][1]
    end

    return nil
end

local function hasAuraMarker(targetGuid)
    return Osi.HasActiveStatus(targetGuid, "PACIFISTS_VOW_AURA_INRANGE") == 1
end

Ext.Osiris.RegisterListener("HitpointsChanged", 2, "after", function(targetGuid, _)
    if not targetGuid or not hasAuraMarker(targetGuid) then
        return
    end

    local hp = Osi.GetHitpoints(targetGuid)
    if not hp or hp > 0 then
        return
    end

    local alreadyKnockedOut = Osi.HasActiveStatus(targetGuid, "KNOCKED_OUT") == 1

    Osi.SetHitpoints(targetGuid, 1)
    if not alreadyKnockedOut then
        Osi.ApplyStatus(targetGuid, "KNOCKED_OUT", -1.0, 1, NULL_GUID)
    end

    local xpSource = getPartyMember()
    if xpSource and not alreadyKnockedOut then
        Osi.ApplyStatus(targetGuid, "PACIFISTS_VOW_XP_STATUS", -1, 1, xpSource)
    end
end)
