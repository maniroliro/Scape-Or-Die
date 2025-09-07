local templateData = {

	inventory = {
		[1] = nil,
		[2] = nil,
		[3] = nil,
		[4] = nil,
		[5] = nil,
		[6] = nil,
	},

	identity = '',
	isWanted = false,
	hasAnIlegalItem = false,

}	

export type TemplateData = typeof(templateData)

return templateData