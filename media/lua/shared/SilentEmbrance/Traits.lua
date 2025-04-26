--[[
*
*              ^_^         Y U M M Y         ^_^
*
*                 ~ Deliciously Made by YUMMY ~
*
*                          :3  :3  :3
*
]]

Events.OnGameBoot.Add(function()
    TraitFactory.addTrait("Heartbreaker", getText("UI_trait_Heartbreaker"), -1, getText("UI_trait_HeartbreakerDesc"),
    false);
    TraitFactory.addTrait("TenderHeart", getText("UI_trait_TenderHeart"), 1, getText("UI_trait_TenderHeartDesc"), false);

    TraitFactory.setMutualExclusive("Heartbreaker", "TenderHeart")
end)
