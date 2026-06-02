extends SkinnablePuppetScript
## Base puppet script for vision-based entities
## Created by Yni, licensed under MIT License
class_name VisionScpPuppetScript

## Amount of watching puppets
var watching_puppets: Array[Node3D] = []
## Stop /freeze object (only for SCP-173)
var freeze: bool = false
