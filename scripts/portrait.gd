extends TextureRect

var actor: ActorData

func link(for_actor: ActorData) -> void:
	actor = for_actor
	self.texture = actor.faceset
