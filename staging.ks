// Staging logic

global staging is false.

function init_staging_logic {
  when staging then {
    STAGE.
    IF stage:nextDecoupler:isType("LaunchClamp")
      STAGE.
    IF stage:nextDecoupler <> "None" {
      WHEN availableThrust = 0 or (
        stage:resourcesLex["LiquidFuel"]:amount = 0 and
        stage:resourcesLex["SolidFuel"]:amount = 0)
      THEN {
        if staging {
          STAGE.
          return stage:nextDecoupler <> "None".
        }
      }
    }
  }
}
