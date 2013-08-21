load 'application'

#instanciate DataSystem
DataSystem = require('./db/DataSystem')
ds = new DataSystem(compound.models)
async = require('async')

action 'index', ->
	redirect('doctypes')

#doctypes
action 'doctypes', ->

#prepare request
	requests = []
	requests.push (callback) -> #0 -> doctypes
		ds.getDoctypes(callback)
	requests.push (callback) -> #1 -> metadoctypes
		ds.getView(callback, DataSystem::PATH.metadoctype_getallbyrelated)
		#ds.applyModelRequest(callback, 'Metadoctype', 'getAllByRelated')
	requests.push (callback) -> #2 -> sums
		ds.getView(callback, DataSystem::PATH.metadoctype_getsumsbydoctype, {group : true})
		#ds.applyModelRequest(callback, 'All', 'getSumsByDoctype', {group : true})
	
	#agregate callback 
	async.parallel requests, (error, results) ->
		jsonRes = []
		if error
			res.send(500, 'Server error occurred while retrieving data')
			console.log error
		else
			for name in results[0]
				newObj = {}
				newObj['name'] = name
				
				for metadoctype in results[1]
					if metadoctype.key? && metadoctype.key.toLowerCase() is name
						newObj['metadoctype'] = metadoctype.value
				
				for info in results[2]
					if info.key? && info.key.toLowerCase() is name
						newObj['sum'] = info.value
				jsonRes.push(newObj)

			res.send(jsonRes)

#doctypes
action 'search', ->

	res.send([{ 'test' : 'search route is ok' }])
