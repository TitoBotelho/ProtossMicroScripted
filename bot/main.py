from typing import Optional

from ares import AresBot
from ares.behaviors.combat.individual import AMove
from cython_extensions import cy_closest_to
from sc2.ids.unit_typeid import UnitTypeId as UnitID
from sc2.position import Point2
from sc2.units import Units


class MyBot(AresBot):
    def __init__(self, game_step_override: Optional[int] = None):
        super().__init__(game_step_override)

    async def on_start(self) -> None:
        await super(MyBot, self).on_start()
        # Micro-arena: keep Ares systems, but disable opening build runner.
        self.build_order_runner.set_build_completed()

    @property
    def attack_target(self) -> Point2:
        origin: Point2 = self.start_location or self.game_info.map_center

        # Prioritize visible enemy units, then enemy structures, then enemy spawn.
        if self.enemy_units:
            return cy_closest_to(origin, self.enemy_units).position
        if self.enemy_structures:
            return cy_closest_to(origin, self.enemy_structures).position
        if self.enemy_start_locations:
            return self.enemy_start_locations[0]
        return self.game_info.map_center

    async def on_step(self, iteration: int) -> None:
        await super(MyBot, self).on_step(iteration)

        target: Point2 = self.attack_target

        # Minimal viable combat loop: every combat unit gets a simple A-move behavior.
        combat_units: Units = self.units.filter(
            lambda u: not u.is_structure and u.type_id not in {UnitID.PROBE}
        )
        for unit in combat_units:
            self.register_behavior(AMove(unit=unit, target=target))
