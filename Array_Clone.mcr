macroScript Array_Clone
category:"Rapida Scripts"
buttonText: "Array Clone"
toolTip:"Clone One of Selected objects\n between two objects"


(
	(
		(
			local obj_array = #()
			local obj_name_array = #()
			fn objArr = 
			( 
				obj_array = #()
				if $ != undefined 
				then (
					if selection.count >=2 then 
					(
						for s = 1 to 2 do appendIfUnique obj_array selection[s] 
					) else ( obj_array = #($) )
				)
			)
			fn objName = 
			(
				obj_name_array = #()
				for o in obj_array do 
				( if o != "none" 
					then (appendIfUnique obj_name_array o.name)
					else (appendIfUnique obj_name_array o))
			)
			local new_objects = #()
			objArr ()
			objName ()
			rollout array_clone "Array Clone" width:264 height:216
			(
				groupBox new_grp "New object" pos:[10,10] width:100 height:90
				radioButtons copy_type "" pos:[20,36] width:73 height:48 labels:#("Copy", "Instance", "Reference") default:2 columns:1
				groupBox copy_grp "Copy of:" pos:[120,10] width:136 height:90
				radioButtons which_obj "" pos:[140,36] width:103 height:16 labels:#("","") columns:1
				label first_item "first" pos:[165,35] width:80 height:16 
				label second_item "second" pos:[165,52] width:80 height:16
				label warn_lbl "select 2 objects" pos:[130, 73] width:100 height:20
				label state_lbl "" pos:[70,110] width:150 height:20
				spinner cnt_spinner "" pos:[10,110] width:50 height:20 range:[1,100,1] type:#integer scale:1
				button do_it "Clone" pos:[20,150] width:100 height:50 enabled:false
				button dont_do_it "Close" pos:[140,150] width:45 height:50 enabled:true
				button delete_it "Delete" pos:[195,150] width:45 height:50 enabled:false
				
				fn enableButtons = 
				(
					do_it.enabled = if obj_array.count == 2 then true else false
					delete_it.enabled = if new_objects.count > 0 then true else false
				)
				fn updateItems = 
				(
					first_item.text = 
					(
						if obj_name_array[1] != undefined then obj_name_array[1] else "Select object"
						)
					second_item.text = 
					(
						if obj_name_array[2] != undefined then obj_name_array[2] else "Select object"
					)
				)
				fn updateLable = 
				(
					state_lbl.text = case copy_type.state of
					(
						1: "Copyes of "
						2: "Instances of "
						3: "References of "
					)
					state_lbl.text += if obj_name_array[1] != undefined then  obj_name_array[which_obj.state] else " nothihg "
				)
				
				fn callBack ev nd = 
					(
						objArr()
						objName()
						updateLable()
						updateItems()
						enableButtons()
							warn_lbl.text = "Yes " + (obj_array.count as string)
						print (obj_name_array as string)
						--format "Selection changed: Event%, Nodes %\n" ev nd 
					)
			
			on copy_type changed state do updateLable()
			on which_obj changed state do updateLable()
			on array_clone open do(
				enableButtons()
				updateItems()
				updateLable()
				(
					callbackItem = NodeEventCallback\
					mouseUp:true\
					delay:1000 selectionChanged:callBack
				)
			)
			on dont_do_it pressed do DestroyDialog array_clone
			on do_it pressed do 
			(
				fn drawLineBetweenTwoPoints pointA pointB div =
				(
					ss = SplineShape pos:pointA vertexTicks:on
					addNewSpline ss
					addKnot ss 1 #corner #line PointA
					addKnot ss 1 #corner #line PointB
					updateShape ss
					subdivideSegment ss 1 1 div
					ss
				)
				newSpline = drawLineBetweenTwoPoints obj_array[1].pos obj_array[2].pos cnt_spinner.value
				num_copies = (numKnots newSpline 1) - 2
				copyfn = case copy_type.state of 
					(
						1: copy
						2: instance
						3: reference
					)
				for i = 2 to (1+num_copies) do 
					(
						newq = copyfn obj_array[which_obj.state] pos:(getKnotPoint newSpline 1 i) wirecolor:obj_array[which_obj.state].wirecolor
						appendIfUnique new_objects newq
					)
					delete newSpline
					enableButtons()
			)
			on array_clone close do 
				(
					callbackItem = undefined
					gc light:true
				)
			on delete_it pressed do 
			(
				if new_objects.count > 0 do 
				(
					delete new_objects
					new_objects = #()
				)
				enableButtons()
			)
			)
		CreateDialog array_clone
		)
	)
)
