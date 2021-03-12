extends Control
class_name InfoBox

func _ready() -> void:
    hide_all()

func display_simple(text: String) -> void:
    hide_all()
    $Simple/NinePatchRect/Label.text = text
    $Simple.show()

func display_plant_arch_id(id: String) -> void:
    hide_all()
    var arch: PlantArch = Plant.ARCHS[id]
    $Plant/NinePatchRect/MarginContainer/VBoxContainer/GridContainer/Name.text = arch.name
    $Plant/NinePatchRect/MarginContainer/VBoxContainer/GridContainer/Cost/Label.text = str(arch.grow_cost)
    $Plant/NinePatchRect/MarginContainer/VBoxContainer/GridContainer/Charges/Label.text = "%d @ %d days" % [arch.spell_charges, arch.growth_period]
    $Plant/NinePatchRect/MarginContainer/VBoxContainer/GridContainer/Watering/Label.text = "%d / %d days" % [arch.watering_quantity, arch.watering_frequency]
    $Plant/NinePatchRect/MarginContainer/VBoxContainer/Description.text = arch.description
    $Plant.show()

func display_plant(plant: Plant) -> void:
    display_plant_arch_id(plant.get_arch_id())

func hide_all() -> void:
    for node in get_children():
        node.hide()
