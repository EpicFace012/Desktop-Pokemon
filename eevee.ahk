#notrayicon
#singleinstance off
#maxhotkeysperinterval 99000000
#hotkeyinterval 99000000
#keyhistory 0
listlines off
setbatchlines -1
setwindelay -1

initialconfig
:=[{name:"Eevee"
	,sprite:"eevee"
	,mode:"eevee"}
,{name:"Female Eevee"
	,sprite:"femaleeevee"
	,mode:"eevee"}
,{name:"Vulpix"
	,sprite:"vulpix"
	,mode:"vulpix"}
,{name:"FluffyVulpix"
	,sprite:"fluffyvulpix"
	,mode:"vulpix"}
,{name:"Zorua"
	,sprite:"zorua"
	,mode:"zorua"}
,{name:"Pikachu"
	,sprite:"pikachu"
	,mode:"pikachu"}
,{name:"Female Pikachu"
	,sprite:"femalepikachu"
	,mode:"pikachu"}
,{name:"Girly Eevee"
	,sprite:"girlyeevee"
	,mode:"eevee"
	,more:1}
,{name:"Possessed Eevee"
	,sprite:"possessedeevee"
	,mode:"eevee"
	,more:1}
,{name:"Faceless Eevee"
	,sprite:"facelesseevee"
	,mode:"eevee"
	,more:1}
,{name:"Choco Eevee"
	,sprite:"chocoeevee"
	,mode:"eevee"
	,more:1}
,{name:"Girly Vulpix"
	,sprite:"girlyvulpix"
	,mode:"vulpix"
	,more:1}
,{name:"Possessed Vulpix"
	,sprite:"possessedvulpix"
	,mode:"vulpix"
	,more:1}
,{name:"Alolan Vulpix"
	,sprite:"alolanvulpix"
	,mode:"vulpix"
	,more:1}]
defaulteevees:={}
defaulteeveesmenu:=[]
loop % initialconfig.length(){
	defaulteevees[initialconfig[a_index].sprite]:=initialconfig[a_index]
	defaulteeveesmenu.push(initialconfig[a_index].sprite)
}
aliases
:={fluffy:"fluffyvulpix"
,female:"femaleeevee"
,girly:"girlyeevee"
,faceless:"facelesseevee"
,choco:"chocoeevee"
,possessed:"possessedeevee"
,girlyfluffy:"girlyvulpix"
,alolan:"alolanvulpix"}
for name,dest in aliases{
	defaulteevees[name]:=defaulteevees[dest]
}
modenames:=["eevee"
,"vulpix"
,"zorua"
,"pikachu"
,"noteevee"]
zoomnames:={tiny:1
,verysmall:2
,smaller:3
,small:4
,default:5
,big:6
,bigger:7
,huge:8}
speedmenu:=[["&Slow",150],["&Normal",100],["&Fast",66]]

gdip_startup()
id:=0
if(!a_args){
	a_args:=[]
	loop %0%{
		a_args.push(%a_index%)
	}
}
alleevees:=[]
loadedimg:={}
thispid:=dllcall("GetCurrentProcessId")
checkprocess()
eeveeargs(a_args)
onmessage(513,"drag")
onmessage(274,"close")
onmessage(123,"menu")
onmessage(74,"addeevee")
settimer update,50

return

eevee(args:=0,force:=0){
	global id,alleevees,defaulteevees,defaulteeveesmenu,modenames,zoomnames,speedmenu
	if(alleevees.length()>=99){
		return
	}
	a:={}
	alleevees.push(a)
	a.id:="eevee" id
	id++
	a.eevees:=defaulteevees.clone()
	a.eeveesmenu:=defaulteeveesmenu.clone()
	a.zoomcurrent:=5
	a.speed:=2
	a.mode:="eevee"
	a.filename:=[]
	if(!args){
		args:=[]
	}
	skipnext:=0
	skipnum:=0
	skipsize:=0
	loop % args.length(){
		if(skipnext){
			skipnext:=0
			continue
		}
		arg:=strlower(args[a_index])
		nextarg:=strlower(args[a_index+1])
		firstsymbol:=substr(arg,1,1)
		if(firstsymbol="/"||firstsymbol="-"){
			argname:=substr(arg,2)
			if(argname="sit"){
				a.sitstate:=1
			}else if(argname="speed"){
				loop % speedmenu.length(){
					if(strlower(strreplace(speedmenu[a_index][1],"&"))=nextarg){
						a.speed:=a_index
						break
					}
				}
				skipnext:=1
			}else if(argname="mode"){
				loop % modenames.length(){
					if(modenames[a_index]=nextarg){
						a.mode:=nextarg
						break
					}
				}
				skipnext:=1
			}else if(argname="fork"){
				skipnext:=1
			}
		}else{
			if(arg="random"||a.eevees[arg]){
				if(!skipnum){
					a.loadnum:=arg
					skipnum:=1
				}
			}else if(zoomnames[arg]){
				if(!skipsize){
					a.zoomcurrent:=zoomnames[arg]
					skipsize:=1
				}
			}else{
				a.filename.push(args[a_index])
			}
		}
	}
	
	allpngs:={}
	loop files,%a_scriptdir%\*.png
	{
		loop % modenames.length(){
			modename:=modenames[a_index]
			if(substr(a_loopfilename,1,strlen(modename))=modename){
				if(!allpngs[modename]){
					allpngs[modename]:=[]
				}
				allpngs[modename].push(a_loopfilename)
				break
			}
		}
	}
	loop % modenames.length(){
		i:=modenames.length()-a_index+1
		modename:=modenames[i]
		if(allpngs[modename]){
			thismode:=allpngs[modename]
			loop % thismode.length(){
				j:=thismode.length()-a_index+1
				a.eevees[thismode[j]]
					:={name:thismode[j]
					,mode:modenames[i]
					,sprite:thismode[j]
					,custom:1}
				a.eeveesmenu.insertat(1,thismode[j])
			}
		}
	}
	loop % a.filename.length(){
		thisfile:=a.filename[a_index]
		if(fileexist(thisfile)){
			shortname:=regexreplace(thisfile,".*[\\/]","")
			a.eevees[shortname]
				:={name:shortname
				,mode:a.mode
				,sprite:thisfile
				,custom:1}
			a.eeveesmenu.insertat(1,shortname)
		}
	}
	if(a.loadnum="random"){
		a.eeveenum:=a.eeveesmenu[random(1,a.eeveesmenu.length())]
	}else if(a.loadnum){
		a.eeveenum:=a.eevees[a.loadnum].sprite
	}
	addmore:=0
	aid:=a.id
	menu tray%aid%,add,&Add,addeevee
	menu tray%aid%,add
	loop % a.eeveesmenu.length(){
		name:=a.eeveesmenu[a_index]
		if(a.eevees[name].more){
			menu more%aid%,add,% a.eevees[name].name,appearance
			if(!addmore){
				menu tray%aid%,add,M&ore,:more%aid%
				addmore:=1
			}
		}else{
			menu tray%aid%,add,% a.eevees[name].name,appearance
		}
	}
	menu tray%aid%,add
	menu tray%aid%,add,&Larger,larger
	menu tray%aid%,add,S&maller,smaller
	menu tray%aid%,add
	loop % speedmenu.length(){
		menu speed%aid%,add,% speedmenu[speedmenu.length()-a_index+1][1],setspeed
	}
	menu tray%aid%,add,&Speed,:speed%aid%
	menu tray%aid%,add,Sto&p running around,sit
	if(a.sitstate){
		menu tray%aid%,check,Sto&p running around
	}
	menu tray%aid%,add,&Close,closeeevee
	if(a.loadnum){
		appearance(,,,a,a.eevees[a.eeveenum],1)
	}else{
		appearance(,,,a,a.eevees[a.eeveesmenu[1]],1)
	}
	config(a,1)
	a.timer:=a_tickcount
	if(!force){
		checkprocess()
	}
	gui %aid%:show,% "na x" a.winx " y" a.winy " w" a.winwidth " h" a.winheight,eevee.exe
	setspeed(,,,a,speedmenu[a.speed][1])
}

winget(byref outvar,cmd,wintitle){
	outvar:=winget%cmd%(wintitle)
}
ifmsgbox(a){
}
setbatchlines(a){
}
strlower(input){
	return format("{:l}",input)
}

config(byref a,initial:=0){
	if(a.changezoom=1){
		if(a.zoomcurrent<a.zoommodes.length()){
			a.changewinx:=(a.winwidth-a.defwidth*a.zoommodes[a.zoomcurrent+1])/2
			a.changewiny:=(a.winheight-a.defheight*a.zoommodes[a.zoomcurrent+1])/2
			a.zoomcurrent++
		}
		
	}else if(a.changezoom=-1){
		if(a.zoomcurrent>1){
			a.changewinx:=(a.winwidth-a.defwidth*a.zoommodes[a.zoomcurrent-1])/2
			a.changewiny:=(a.winheight-a.defheight*a.zoommodes[a.zoomcurrent-1])/2
			a.zoomcurrent--
		}
	}
	a.changezoom:=0
	a.updateconfig:=0
	a.zoommodes:=[1,1.5,2,2.5,3,4,5,6]
	a.zoom:=a.zoommodes[a.zoomcurrent]
	if(a.mode="eevee"){
		a.zoommodes:=[1,1.5,2,2.5,3,4,5,6]
		a.zoomdrawn:=[1,2,2,3,3,4,5,6]
		a.wzoom:=a.zoommodes[a.zoomcurrent]
		a.defwidth:=50
		a.defheight:=48
		a.winwidth:=a.defwidth*a.wzoom
		a.winheight:=a.defheight*a.wzoom
		a.head:=["151x5 17x18 10x10","119x22 17x18 10x10","119x41 17x18 10x10","104x73 17x18 10x10","106x0 17x17 10x11","124x1 17x16 10x12"]
		a.headrun:=[5,4,2,3,1]
		a.body:=["149x24 23x18 8x20"]
		a.leftear:=["22x59 7x18 10x0","31x61 5x14 9x4","38x61 7x14 7x4","142x0 8x13 5x5","36x77 10x12 3x6","24x79 11x10 2x8","10x80 13x9 0x9"]
		a.leftearrun:=[3,2,1,2,3,4,5,6,7,6,5,4]
		a.rightear:=["79x59 11x15 20x0","64x61 13x14 20x3","48x63 15x12 20x4","169x2 17x10 20x7","48x79 18x8 20x10","67x81 18x7 20x12","86x83 17x7 21x13"]
		a.rightearrun:=[3,2,1,2,3,4,5,6,7,6,5,4]
		a.legs:=["152x43 27x17 11x27","1x1 32x20 7x27","34x0 36x14 7x26","71x0 34x18 7x25","0x23 28x18 8x24","29x22 26x19 10x26","56x23 24x17 12x27","81x23 24x17 12x28","78x41 27x17 9x29","122x74 27x16 11x27","116x100 27x18 11x28"]
		a.legsrun:=[2,4,5,6,7,9]
		a.bodyrun:=[1,1,1,1,1,1]
		a.legsjump:=[2,4,5,1]
		a.bodyjump:=[1,1,1,1]
		a.tail:=["190x68 17x24 26x9","171x68 17x24 27x9","151x67 19x24 27x9","181x26 19x23 28x10","144x96 21x21 28x13","166x98 21x19 28x17","189x101 22x17 27x20"]
		a.tailrun:=[5,6,7,6,5,4,3,2,1,2,3,4]
		a.trayicon:=["181x26 19x23 28x10","149x24 23x18 8x20","152x43 27x17 11x27","142x0 8x13 5x5","151x5 17x18 10x10","169x2 17x10 20x7"]
		a.trayiconxy:=[9,10]
	}else if(a.mode="vulpix"){
		a.zoommodes:=[1,1.33,1.66,2,2.5,3,4,5]
		a.zoomdrawn:=[1,2,2,2,3,3,4,5]
		a.wzoom:=a.zoommodes[a.zoomcurrent]
		a.defwidth:=68
		a.defheight:=54
		a.winwidth:=a.defwidth*a.wzoom
		a.winheight:=a.defheight*a.wzoom
		a.head:=["0x0 27x26 3x6","0x27 27x26 3x6","0x54 27x26 3x6","0x81 27x26 3x6","112x34 27x25 3x7"]
		a.headrun:=[5,4,2,3,1]
		a.body:=["28x0 30x17 15x26","28x19 30x19 15x26","28x39 30x18 15x25"]
		a.leftear:=["0x0 0x0 -1x0"]
		a.leftearrun:=[1,1,1,1,1,1,1,1,1,1,1,1]
		a.rightear:=["0x0 0x0 -1x0"]
		a.rightearrun:=[1,1,1,1,1,1,1,1,1,1,1,1]
		a.legs:=["59x0 38x15 10x36","59x16 47x23 1x30","59x40 52x13 0x34","59x54 40x18 6x31","112x0 31x16 13x35","112x17 30x16 16x37","144x0 33x16 16x37","144x17 43x16 6x37"]
		a.legsrun:=[8,2,3,4,5,6]
		a.bodyrun:=[2,2,1,3,1,2]
		a.legsjump:=[2,4,5,1]
		a.bodyjump:=[2,3,1,1]
		a.tail:=["101x76 33x31 28x1","65x76 34x31 29x2","29x76 34x31 30x4","136x74 34x33 31x5","172x74 33x33 34x7"]
		a.tailrun:=[3,3,2,1,2,3,3,4,5,4,3,3]
		a.trayicon:=["29x76 34x31 30x4","28x0 30x17 15x26","59x0 38x15 10x36","0x0 27x26 3x6"]
		a.trayiconxy:=[3,15]
	}else if(a.mode="zorua"){
		a.zoommodes:=[1,1.5,2,2.5,3,4,5,6]
		a.zoomdrawn:=[1,2,2,3,3,4,5,6]
		a.wzoom:=a.zoommodes[a.zoomcurrent]
		a.defwidth:=51
		a.defheight:=57
		a.winwidth:=a.defwidth*a.wzoom
		a.winheight:=a.defheight*a.wzoom
		a.head:=["0x0 28x35 5x1","0x36 28x35 5x1","0x72 28x35 5x0","0x109 28x35 5x0","84x109 28x36 5x0"]
		a.headrun:=[5,4,2,5,1,3,1]
		a.body:=["29x72 29x22 10x24","29x95 29x20 10x24","0x0 0x0 -1x0"]
		a.leftear:=["29x0 9x11 7x9","29x0 9x11 7x9","29x18 10x10 6x12","29x33 10x10 4x12","29x47 12x11 1x15","29x59 11x9 1x18"]
		a.leftearrun:=[5,6,5,4,3,4,3,4,5,6,5,4]
		a.rightear:=["42x0 13x17 21x9","42x0 13x17 21x9","42x18 14x14 21x11","42x33 15x13 21x12","42x47 16x11 21x15","42x59 16x12 21x16"]
		a.rightearrun:=[5,6,5,4,3,4,3,4,5,6,5,4]
		a.legs:=["59x0 26x12 13x41","59x13 30x12 9x42","59x26 34x8 9x42","59x35 33x9 8x43","59x45 28x12 11x40","59x58 25x12 13x41","59x71 23x12 12x41","59x84 29x11 10x43"]
		a.legsrun:=[8,2,3,4,5,6]
		a.bodyrun:=[1,1,1,1,2,1]
		a.legsjump:=[2,4,5,1]
		a.bodyjump:=[1,1,2,1]
		a.tail:=["94x0 13x24 32x14","94x25 14x22 34x17","94x48 15x21 34x19","94x70 16x19 34x22","94x90 18x17 33x26"]
		a.tailrun:=[3,3,2,1,2,3,3,4,5,4,3,3]
		a.trayicon:=["29x72 29x22 10x24","42x33 15x13 21x12","0x0 28x35 5x1"]
		a.trayiconxy:=[5,19]
	}else if(a.mode="pikachu"){
		a.zoommodes:=[1,1.5,2,2.5,3,4,5,6]
		a.zoomdrawn:=[1,2,2,3,3,4,5,6]
		a.wzoom:=a.zoommodes[a.zoomcurrent]
		a.defwidth:=70
		a.defheight:=45
		a.winwidth:=a.defwidth*a.wzoom
		a.winheight:=a.defheight*a.wzoom
		a.head:=["0x0 27x23 20x4","28x0 27x23 20x4","56x0 27x23 20x4","84x0 27x23 20x4","0x71 27x21 20x6","28x71 27x21 20x6","56x71 27x21 20x6","0x24 27x23 20x6","28x24 27x23 20x6","56x24 27x23 20x6","84x24 27x23 20x6","0x47 27x23 20x5","28x47 27x23 20x5","56x47 27x23 20x5","84x47 27x23 20x5"]
		a.headrun:=[5,4,1,3,2,4,3,1]
		a.body:=["112x0 18x21 41x16","112x22 18x19 41x18","112x42 21x18 41x20","112x42 21x18 47x14","112x22 18x19 49x8","112x0 18x21 48x0","112x0 18x21 48x1","112x22 18x19 49x9"]
		a.leftear:=["0x0 0x0 -1x0"]
		a.leftearrun:=[1,1,1,1,1,1,1,1,1,1,1,1]
		a.rightear:=["0x0 0x0 -1x0"]
		a.rightearrun:=[1,1,1,1,1,1,1,1,1,1,1,1]
		a.legs:=["84x71 21x17 21x27","106x71 21x17 21x27","128x71 21x17 21x27","0x93 31x20 18x21","32x93 36x15 19x21","69x93 27x18 23x18","97x93 26x18 24x19","124x93 27x19 23x20"]
		a.legsrun:=[4,5,6,7,8]
		a.bodyrun:=[4,5,6,7,8]
		a.legsjump:=[4,6,7,1]
		a.bodyjump:=[4,6,7,1]
		a.tail:=["0x0 0x0 -1x0","0x0 0x0 -1x0","0x0 0x0 -1x0"]
		a.tailrun:=[1,2,3,3,3,2,1,1,1,1,1,1]
		a.trayicon:=["84x71 21x17 1x22","0x0 27x23 0x0"]
		a.trayiconxy:=[0,8]
	}else if(a.mode="noteevee"){
		a.zoommodes:=[.33,.5,.66,.83,1,1.33,1.66,2]
		a.zoomdrawn:=[1,1,1,1,1,2,2,2]
		a.wzoom:=a.zoommodes[a.zoomcurrent]
		a.defwidth:=gdip_getimagewidth(a.eevee)
		a.defheight:=gdip_getimageheight(a.eevee)
		a.winwidth:=a.defwidth*a.wzoom
		a.winheight:=a.defheight*a.wzoom
		a.allheads:="0x0 " a.defwidth "x" a.defheight " 0x0"
		a.head:=[a.allheads,a.allheads,a.allheads,a.allheads,a.allheads]
		a.headrun:=[1,1,1,1,1]
		a.body:=["0x0 0x0 -1x0"]
		a.leftear:=["0x0 0x0 -1x0"]
		a.leftearrun:=[1,1,1,1,1,1,1,1,1,1,1,1]
		a.rightear:=["0x0 0x0 -1x0"]
		a.rightearrun:=[1,1,1,1,1,1,1,1,1,1,1,1]
		a.legs:=["0x0 0x0 -1x0"]
		a.legsrun:=[1,1,1,1,1,1]
		a.bodyrun:=[1,1,1,1,1,1]
		a.legsjump:=[1,1,1,1]
		a.bodyjump:=[1,1,1,1]
		a.tail:=["0x0 0x0 -1x0"]
		a.tailrun:=[1,1,1,1,1,1,1,1,1,1,1,1]
		a.trayicon:=0
		a.trayiconxy:=0
	}
	aid:=a.id
	if(initial){
		a.winx:=random(100,a_screenwidth-a.winwidth-100)
		a.winy:=random(100,a_screenheight-a.winheight-100)
		a.tick:=0
		a.headn:=1
		a.headrunn:=0
		a.headtilt:=0
		a.bodyn:=1
		a.leftearn:=4
		a.leftearrunn:=0
		a.lefteardir:=1
		a.rightearn:=4
		a.rightearrunn:=0
		a.lefteardir:=1
		a.legsn:=1
		a.legsrunn:=0
		a.legscamrun:=[-1,-1,-1,1,1,1]
		a.legscontinue:=0
		a.jumpcamrun:=[-1,-1,1,1]
		a.legsjumpn:=0
		a.tailn:=4
		a.tailrunn:=0
		a.rundir:=0
	}else{
		gdip_deletegraphics(a.gbitmap)
		gdip_disposeimage(a.pbitmap)
		selectobject(a.hdc,a.obm)
		deleteobject(a.hbm)
		deletedc(a.hdc)
		gdip_deletegraphics(a.g)
		gui %aid%:destroy
	}
	gui %aid%:-caption +e524288 +e128 +owndialogs +owner +alwaysontop +hwndhwnd1 -dpiscale
	a.hwnd:=hwnd1
	if(initial!=1){
		try{
			gui %aid%:show,% "x" a.winx " y" a.winy " w" a.winwidth " h" a.winheight,eevee.exe
		}catch{
			config(a,2)
			return
		}
	}
	a.hbm:=createdibsection(a.winwidth,a.winheight)
	a.hdc:=createcompatibledc()
	a.obm:=selectobject(a.hdc,a.hbm)
	a.g:=gdip_graphicsfromhdc(a.hdc)
	gdip_setinterpolationmode(a.g,7)
	a.pbitmap:=gdip_createbitmap(a.defwidth*a.zoomdrawn[a.zoomcurrent],a.defheight*a.zoomdrawn[a.zoomcurrent])
	a.gbitmap:=gdip_graphicsfromimage(a.pbitmap)
	gdip_setinterpolationmode(a.gbitmap,5)
	if(a.flipped){
		gdip_scaleworldtransform(a.g,-1,1)
		gdip_translateworldtransform(a.g,-a.winwidth,0)
	}
	if(a.zoomcurrent=a.zoommodes.length()){
		menu tray%aid%,disable,&Larger
	}else{
		menu tray%aid%,enable,&Larger
	}
	if(a.zoomcurrent=1){
		menu tray%aid%,disable,S&maller
	}else{
		menu tray%aid%,enable,S&maller
	}
}

random(min,max){
	random out,%min%,%max%
	return out
}

update(){
	global alleevees
	loop % alleevees.length(){
	a:=alleevees[a_index]
	if(a&&a_tickcount-a.speedms>=a.timer){
	a.timer:=a_tickcount
	if(a.updateconfig){
		config(a)
	}
	if(winactive("ahk_id " a.hwnd)){
		up:=getkeystate("up")
		right:=getkeystate("right")
		down:=getkeystate("down")
		left:=getkeystate("left")
		space:=getkeystate("space")||getkeystate("enter")
		ctrl:=getkeystate("lctrl")||getkeystate("rctrl")
		justflipped:=0
		if(!getkeystate("lbutton")&&a.dragging){
			wingetpos winx,winy,,,% "ahk_id" a.hwnd
			updatesize(a,winx,winy)
			a.dragging:=0
			a.headrunn:=1
			a.running:=0
		}
		if(up&&!a.up){
			if(ctrl){
				larger(,,,a)
			}else{
				a.rundir:=-1
			}
		}
		if(right&&!a.right&&!a.flipped){
			gdip_scaleworldtransform(a.g,-1,1)
			gdip_translateworldtransform(a.g,-a.winwidth,0)
			a.lastflip:=a.tick
			a.flipped:=1
			justflipped:=1
		}
		if(down&&!a.down){
			if(ctrl){
				smaller(,,,a)
			}else{
				a.rundir:=1
			}
		}
		if(left&&!a.left&&a.flipped){
			gdip_resetworldtransform(a.g)
			a.lastflip:=a.tick
			a.flipped:=0
			justflipped:=1
		}
		if((a.up||a.down)&&!up&&!down){
			a.rundir:=0
		}
		if(left||right){
			if(!justflipped){
				a.running:=1
				a.manualrun:=1
			}
		}else if(a.left||a.right){
			a.running:=0
			a.manualrun:=0
			a.lastmanualrun:=a.tick
		}
		if(space&&!a.space){
			a.headrunn:=1
		}
		a.up:=up
		a.right:=right
		a.down:=down
		a.left:=left
		a.space:=space
	}else{
		a.left:=0
		a.right:=0
		if(a.manualrun){
			a.running:=0
			a.manualrun:=0
			a.lastmanualrun:=a.tick
		}
	}
	gdip_graphicsclear(a.g)
	gdip_graphicsclear(a.gbitmap)
	a.eyesopen:=random(0,20)
	if(a.tick>0&&a.dragging){
		wingetpos winx,winy,,,% "ahk_id " a.hwnd
		updatesize(a,winx,winy)
	}
	a.atleftside:=!a.flipped&&a.winx-a.zoom*40<0
	a.atrightside:=a.flipped&&a.winx+a.zoom*40+a.winwidth>a_screenwidth
	if(a.dragging){
		a.legscontinue:=0
		a.headrunn:=1
		a.running:=0
		if(a.mode="pikachu"){
			if(a.bodyn>3||a.bodyn=1){
				a.bodyn:=2
			}else{
				a.bodyn:=3
			}
		}else{
			a.bodyn:=1
		}
		a.legsrunn:=0
		a.legsjumpn:=0
		a.tailrunn:=0
		a.leftearrunn:=0
		a.rightearrunn:=0
		a.bothearrun:=0
		if(a.mode="eevee"){
			a.legsn:=11
		}else{
			a.legsn:=1
		}
		a.lastflip:=a.tick
		a.lastrun:=a.tick
		a.lasthead:=a.tick
		if(a.mode="pikachu"){
			if(a.eyesopen){
				a.headn:=6
			}else{
				a.headn:=7
			}
		}else{
			if(a.eyesopen){
				a.headn:=3
			}else{
				a.headn:=4
			}
		}
		if(a.leftearn>1){
			a.leftearn--
		}
		if(a.rightearn>1){
			a.rightearn--
		}
		if(a.mode="eevee"){
			a.tailn:=4
		}else if(a.tailn>1){
			a.tailn--
		}
	}else{
		a.tick++
		if(a.sitstate){
			a.running:=0
			a.legsrunn:=0
			a.legsjumpn:=0
			if(a.mode="vulpix"){
				a.bodyn:=2
			}else{
				a.bodyn:=1
			}
		}else if(a.running){
			a.legscontinue:=1
			a.legsjumpn:=1
			if(!a.legsrunn){
				a.legsrunn:=1
			}
			if(!a.manualrun&&(a.atrightside||a.atleftside||!random(0,10))){
				a.legscontinue:=0
				a.running:=0
				a.lastrun:=a.tick
			}
		}else{
			if(a.tick=1&&a.winx<a_screenwidth//2||!a.legsjumpn&&a.lastmanualrun+50<a.tick&&a.lastflip+10<a.tick&&a.lastrun+10<a.tick&&((a.atrightside||a.atleftside)&&!random(0,10)||!random(0,100))){
				if(a.flipped){
					gdip_resetworldtransform(a.g)
				}else{
					gdip_scaleworldtransform(a.g,-1,1)
					gdip_translateworldtransform(a.g,-a.winwidth,0)
				}
				a.flipped:=!a.flipped
				a.lastflip:=a.tick
			}else if(a.lastmanualrun+50<a.tick&&!a.atrightside&&!a.atleftside&&a.lastrun+10<a.tick&&!random(0,50)){
				a.running:=1
				if(a.winy-a.zoom*40<0){
					a.rundir:=random(0,1)
				}else if(a.winy+a.zoom*40+a.winheight>a_screenheight){
					a.rundir:=random(-1,0)
				}else{
					a.rundir:=random(-1,1)
				}
			}
		}
		if(a.headrunn){
			a.headn:=a.headrun[a.headrunn]
			a.headrunn:=mod(a.headrunn+1,a.headrun.length()+1)
		}else{
			if(a.eyesopen){
				a.headn:=1
			}else{
				a.headn:=2
			}
			if(a.lasthead+100<a.tick&&!random(0,200)){
				a.headrunn:=1
				a.lasthead:=a.tick
			}
		}
		if(a.legsrunn){
			if(a.flipped){
				a.winx:=a.winx+a.zoom*4
			}else{
				a.winx:=a.winx-a.zoom*4
			}
			a.winy:=a.winy+(a.legscamrun[a.legsrunn]+a.rundir)*a.zoom
			a.legsn:=a.legsrun[a.legsrunn]
			a.bodyn:=a.bodyrun[a.legsrunn]
			a.legsrunn:=mod(a.legsrunn+1,a.legsrun.length()+1)
		}else if(a.legsjumpn){
			if(a.flipped){
				a.winx:=a.winx+a.zoom*4
			}else{
				a.winx:=a.winx-a.zoom*4
			}
			a.winy:=a.winy+(a.jumpcamrun[a.legsjumpn]+a.rundir)*a.zoom
			a.legsn:=a.legsjump[a.legsjumpn]
			a.bodyn:=a.bodyjump[a.legsjumpn]
			a.legsjumpn:=mod(a.legsjumpn+1,a.legsjump.length()+1)
		}else{
			a.legsn:=1
			if(a.mode!="pikachu"){
				a.bodyn:=1
			}
		}
		if(a.mode="pikachu"){
			if(a.lasttilt+20<a.tick&&!random(0,50)){
				if(a.headtilt>0){
					a.headtilt:=0
				}else{
					a.headtilt:=random(0,2)
				}
				a.lasttilt:=a.tick
			}
			if(!a.running&&!a.legsjumpn){
				if(a.headtilt>0){
					if(a.headn=5){
						a.headn:=1
					}
					if(a.headn=6||a.headn=7){
						a.headn-=3
					}
					a.headn+=a.headtilt*4+3
				}
				a.legsn:=a.headtilt+1
				if(a.tailrunn){
					a.bodyn:=a.tailrun[a.tailrunn]
					a.tailrunn++
					if(a.tailrunn=7){
						a.tailrunn:=0
					}
				}else if(a.bodyn>1){
					a.bodyn--
				}
			}
		}
		if(a.tailrunn){
			a.tailn:=a.tailrun[a.tailrunn]
			a.tailrunn:=mod(a.tailrunn+1,a.tailrun.length()+1)
			if(a.tailrunn=7&&random(0,10)){
				a.tailrunn:=0
			}
		}else if(a.tailn<3){
			a.tailn++
		}else{
			if(!random(0,10)){
				a.tailrunn:=random(0,1)?1:7
			}
		}
		if(!a.leftearrunn&&!a.rightearrunn&&!random(0,100)){
			a.leftearrunn:=7
			a.lefteardir:=1
			a.rightearrunn:=7
			a.righteardir:=1
			a.bothearrun:=1
		}
		if(a.leftearrunn){
			a.leftearn:=a.leftearrun[a.leftearrunn]
			if(!random(0,100)){
				a.leftearrunn:=0
				if(a.bothearrun){
					a.rightearrunn:=0
				}
			}else{
				if(!random(0,5)){
					a.lefteardir:=random(0,1)?1:-1
					if(a.bothearrun){
						a.righteardir:=a.lefteardir
					}
				}
				a.leftearrunn:=mod(a.leftearrunn+a.lefteardir,a.leftearrun.length()+1)
			}
		}else{
			a.bothearrun:=0
			if(!random(0,100)){
				a.leftearrunn:=7
				a.lefteardir:=1
			}else if(a.leftearn<4){
				a.leftearn++
			}else if(a.rightearn>4){
				a.leftearn--
			}
		}
		if(a.rightearrunn){
			a.rightearn:=a.rightearrun[a.rightearrunn]
			if(!a.bothearrun&&!random(0,100)){
				a.rightearrunn:=0
			}else{
				if(!a.bothearrun&&!random(0,5)){
					a.righteardir:=random(0,1)?1:-1
				}
				a.rightearrunn:=mod(a.rightearrunn+a.righteardir,a.rightearrun.length()+1)
			}
		}else{
			a.bothearrun:=0
			if(!random(0,100)){
				a.rightearrunn:=7
				a.righteardir:=1
			}else if(a.rightearn<4){
				a.rightearn++
			}else if(a.rightearn>4){
				a.rightearn--
			}
		}
	}
	if(a.mode="vulpix"&&a.bodyn=2){
		drawpart(a,a.tail[a.tailn],0,4)
	}else{
		drawpart(a,a.tail[a.tailn])
	}
	if(a.mode="pikachu"&&(a.legsrunn||a.legsjumpn)){
		drawpart(a,a.head[a.headn])
	}
	drawpart(a,a.body[a.bodyn])
	drawpart(a,a.legs[a.legsn])
	drawpart(a,a.leftear[a.leftearn])
	if(a.mode!="pikachu"||a.mode="pikachu"&&!a.legsrunn&&!a.legsjumpn){
		drawpart(a,a.head[a.headn])
	}
	drawpart(a,a.rightear[a.rightearn])
	if(!a.dragging){
		if(a.winx>a_screenwidth-a.winwidth){
			a.winx:=a_screenwidth-a.winwidth
		}
		if(a.winx<0){
			a.winx:=0
		}
		if(a.winy>a_screenheight-a.winheight){
			a.winy:=a_screenheight-a.winheight
		}
		if(a.winy<0){
			a.winy:=0
		}
		if(a.changewinx){
			a.winx:=a.winx+a.changewinx
			a.changewinx:=0
		}
		if(a.changewiny){
			a.winy:=a.winy+a.changewiny
			a.changewiny:=0
		}
	}
	gdip_drawimage(a.g,a.pbitmap,0,0,a.winwidth,a.winheight,0,0,a.defwidth*a.zoomdrawn[a.zoomcurrent],a.defheight*a.zoomdrawn[a.zoomcurrent])
	if(a.mode="pikachu"&&(a.legsrunn||a.legsjumpn)){
		updatelayeredwindow(a.hwnd,a.hdc,a.winx,a.winy+a.zoomdrawn[a.zoomcurrent]*3,a.winwidth,a.winheight)
	}else{
		updatelayeredwindow(a.hwnd,a.hdc,a.winx,a.winy,a.winwidth,a.winheight)
	}
	}
	}
}

drawpart(byref a,coord,x:=0,y:=0){
	zoom:=a.zoomdrawn[a.zoomcurrent]
	pos:=strsplit(coord," ")
	postl:=strsplit(pos[1],"x")
	poswh:=strsplit(pos[2],"x")
	posxy:=strsplit(pos[3],"x")
	gdip_drawimage(a.gbitmap,a.eevee,(posxy[1]+x)*zoom,(posxy[2]+y)*zoom,poswh[1]*zoom+zoom,poswh[2]*zoom+zoom,postl[1]-1,postl[2]-1,poswh[1]+1,poswh[2]+1)
}

drag(){
	if(getcurrent(a)){
		a.dragging:=1
		postmessage 161,2
		keywait lbutton
		wingetpos winx,winy,,,% "ahk_id " a.hwnd
		updatesize(a,winx,winy)
		a.dragging:=0
		a.headrunn:=1
	}
}

checkprocess(){
	global thispid,a_args
	winget anotherpid,pid,eevee.exe ahk_class AutoHotkeyGUI
	if(anotherpid&&thispid!=anotherpid){
		loop % a_args.length(){
			if(a_index=1){
				allargs:=a_args[1]
			}else{
				allargs:=allargs "`n" a_args[a_index]
			}
		}
		varsetcapacity(data,a_ptrsize*3,0)
		numput(strlen(allargs)*2+2,data,a_ptrsize)
		numput(&allargs,data,a_ptrsize*2)
		sendmessage 74,0,% &data,,ahk_pid %anotherpid%
		exitapp
	}
}

addeevee(wparam:=0,lparam:=0,msg:=0,hwnd:=0){
	critical
	if(wparam!="&Add"){
		eeveeargs(strsplit(strget(numget(lparam+a_ptrsize*2)),"`n"),1)
		return 1
	}
	eevee(,1)
}

eeveeargs(args,force:=0){
	global defaulteevees,zoomnames,defaulteeveesmenu
	forkcount:=0
	randomize:=1
	skipnext:=0
	loop % args.length(){
		if(skipnext){
			skipnext:=0
			continue
		}
		arg:=strlower(args[a_index])
		firstsymbol:=substr(arg,1,1)
		if(firstsymbol="/"||firstsymbol="-"){
			argname:=substr(arg,2)
			if(argname="fork"){
				nextarg:=floor(args[a_index+1])
				if(nextarg>=1&&nextarg<=99){
					forkcount:=nextarg
				}
				skipnext:=1
			}else if(argname="speed"||argname="mode"){
				skipnext:=1
			}else if(argname!="sit"){
				randomize:=0
			}
		}else if(randomize&&zoomnames[arg]){
			randomize:=2
		}else{
			randomize:=0
		}
	}
	if(forkcount){
		loop % forkcount{
			if(randomize){
				nargs:=args.clone()
				nargs.insertat(1,"random")
				eevee(nargs,force)
			}else{
				eevee(args,force)
			}
		}
	}else{
		eevee(args,force)
	}
}

appearance(b:=0,c:=0,d:=0,byref a:=0,thismenu:=0,noconfig:=0){
	global defaulteeveesmenu
	if(!a){
		tray:=substr(a_thismenu,1,4)
		getcurrent(a,a_thismenu,tray)
		loop % a.eeveesmenu.length(){
			thismenu:=a.eevees[a.eeveesmenu[a_index]]
			if(a_thismenuitem=thismenu.name){
				break
			}
		}
	}
	if(a){
		aid:=a.id
		if(a.appearance){
			trayaid:=a.appearance.trayaid
			menu %trayaid%,uncheck,% a.appearance.name
		}else{
			a.appearance:={}
		}
		if(thismenu.more){
			trayaid:="more" aid
		}else{
			trayaid:="tray" aid
		}
		a.appearance:={trayaid:trayaid,name:thismenu.name}
		if(thismenu.custom){
			a.eevee:=loadfromfile(thismenu.sprite)
		}else{
			a.eevee:=loadimage(thismenu.sprite)
		}
		menu %trayaid%,check,% thismenu.name
		a.mode:=thismenu.mode
		a.dragging:=0
		if(!noconfig){
			a.updateconfig:=1
		}
	}
}

larger(b:=0,c:=0,d:=0,byref a:=0){
	if(a||getcurrent(a,a_thismenu,"tray")){
		if(a.zoomcurrent<a.zoommodes.length()){
			a.changezoom:=1
			a.updateconfig:=1
		}
		a.dragging:=0
	}
}
smaller(b:=0,c:=0,d:=0,byref a:=0){
	if(a||getcurrent(a,a_thismenu,"tray")){
		if(a.zoomcurrent>1){
			a.changezoom:=-1
			a.updateconfig:=1
		}
		a.dragging:=0
	}
}
setspeed(b:=0,c:=0,d:=0,byref a:=0,thismenu:=0){
	global speedmenu
	if(!a){
		thismenu:=a_thismenuitem
		getcurrent(a,a_thismenu,"speed")
	}
	if(a){
		aid:=a.id
		loop % speedmenu.length(){
			if(speedmenu[a_index][1]=thismenu){
				menu speed%aid%,check,% thismenu
				a.speedms:=speedmenu[a_index][2]
			}else{
				menu speed%aid%,uncheck,% speedmenu[a_index][1]
			}
		}
	}
}
sit(){
	if(getcurrent(a,a_thismenu,"tray")){
		menu % "tray" a.id,togglecheck,Sto&p running around
		a.sitstate:=!a.sitstate
		a.dragging:=0
	}
}

getcurrent(byref a,hwnd:=0,menu:=0){
	global alleevees
	if(!hwnd){
		hwnd:=winexist("a")
	}
	if(hwnd){
		loop % alleevees.length(){
			if(menu&&hwnd=menu alleevees[a_index].id||hwnd=alleevees[a_index].hwnd){
				a:=alleevees[a_index]
				return 1
			}
		}
	}
}

updatesize(byref a,winx,winy){
	if(winx){
		a.winx:=winx
	}else{
		a.winx:=0
	}
	if(winy){
		a.winy:=winy
	}else{
		a.winy:=0
	}
}

close(wparam){
	if(wparam=61536){
		return 1
	}
}

closeeevee(b:=0,c:=0,d:=0,byref a:=0){
	global alleevees,shift
	if(a){
		thismenu:="tray" a.id
	}else if(shift){
		n:=random(1,3)
		if(n=1){
			text:="The cute eevees are very sad to see you go 3:"
		}else if(n=2){
			text:="Will you open more cute eevees soon?"
		}else if(n=3){
			text:="Close the cute eevees and be an ugly eevee forever?"
		}
		msgbox 262404,Eevees,%text%
		if(a_msgboxresult="Yes"){
			exitapp
		}else if(a_msgboxresult=""){
			ifmsgbox yes
				exitapp
		}
		return
	}else{
		thismenu:=a_thismenu
	}
	loop % alleevees.length(){
		aid:=alleevees[a_index].id
		if(a_thismenu="tray" aid){
			gui %aid%:destroy
			alleevees.removeat(a_index)
			break
		}
	}
	if(!alleevees.length()){
		exitapp
	}
}

menu(wparam,lparam,msg,hwnd){
	global shift
	coordmode menu,screen
	getcurrent(a,hwnd)
	aid:=a.id
	if(getkeystate("shift")){
		n:=random(1,3)
		if(n=1){
			text:="Become an eevee"
		}else if(n=2){
			text:="Secret button don't click"
		}else if(n=3){
			text:="Don't be mean to eevees!"
		}
		menu tray%aid%,rename,&Close,%text%
		shift:=1
	}
	x:=lparam&65535
	y:=(lparam>>16)&65535
	menu tray%aid%,show,%x%,%y%
	if(shift){
		menu tray%aid%,rename,%text%,&Close
		shift:=0
	}
}

; GDIP

gdip_startup(){
dllcall("LoadLibrary",str,"gdiplus")
varsetcapacity(s,a_ptrsize=8?24:16,0)
s:=chr(1)
r:=a_ptrsize=8?"uptr":"uint"
dllcall("gdiplus\GdiplusStartup",a_ptrsize=8?"uptrp":"uintp",t,r,&s,r,0)
return t
}
createdibsection(w,h){
varsetcapacity(i,40,0)
numput(w,i,4,"uint")
numput(h,i,8,"uint")
numput(40,i,0,"uint")
numput(1,i,12,"ushort")
numput(0,i,16,"uint")
numput(32,i,14,"ushort")
c:=getdc()
r:=a_ptrsize=8?"uptr":"uint"
m:=dllcall("CreateDIBSection",r,c,r,&i,uint,0,a_ptrsize=8?"uptrp":"uintp",0,r,0,uint,0,r)
releasedc(c)
return m
}
createcompatibledc(){
return dllcall("CreateCompatibleDC",a_ptrsize=8?"uptr":"uint",0)
}
selectobject(c,m){
r:=a_ptrsize=8?"uptr":"uint"
return dllcall("SelectObject",r,c,r,m)
}
gdip_graphicsfromhdc(c){
dllcall("gdiplus\GdipCreateFromHDC",a_ptrsize=8?"uptr":"uint",c,a_ptrsize=8?"uptrp":"uintp",g)
return g
}
gdip_setinterpolationmode(g,m){
dllcall("gdiplus\GdipSetInterpolationMode",a_ptrsize=8?"uptr":"uint",g,int,m)
}
gdip_createbitmapfromfile(f){
if(a_isunicode){
dllcall("gdiplus\GdipCreateBitmapFromFile",uint,&f,uintp,p)
}else{
varsetcapacity(w,1023)
dllcall("kernel32\MultiByteToWideChar",uint,0,uint,0,uint,&f,int,-1,uint,&w,int,512)
dllcall("gdiplus\GdipCreateBitmapFromFile",uint,&w,uintp,p)
}
return p
}
gdip_graphicsclear(g){
dllcall("gdiplus\GdipGraphicsClear",a_ptrsize=8?"uptr":"uint",g,int,16777215)
}
gdip_resetworldtransform(g){
dllcall("gdiplus\GdipResetWorldTransform",a_ptrsize=8?"uptr":"uint",g)
}
gdip_scaleworldtransform(g,x,y){
dllcall("gdiplus\GdipScaleWorldTransform",a_ptrsize=8?"uptr":"uint",g,float,x,float,y,int,0)
}
gdip_translateworldtransform(g,x,y){
dllcall("gdiplus\GdipTranslateWorldTransform",a_ptrsize=8?"uptr":"uint",g,float,x,float,y,int,0)
}
updatelayeredwindow(d,c,x,y,w,h){
varsetcapacity(t,8)
numput(x,t,0,"uint")
numput(y,t,4,"uint")
r:=a_ptrsize=8?"uptr":"uint"
return dllcall("UpdateLayeredWindow",r,d,r,0,r,&t,int64p,w|h<<32,r,c,int64p,0,uint,0,uintp,33488896,uint,2)
}
gdip_drawimage(x,y,a,b,c,d,e,f,g,h){
r:=a_ptrsize=8?"uptr":"uint"
return dllcall("gdiplus\GdipDrawImageRectRect",r,x,r,y,float,a,float,b,float,c,float,d,float,e,float,f,float,g,float,h,int,2,r,0,r,0,r,0)
}
gdip_disposeimage(p){
dllcall("gdiplus\GdipDisposeImage",a_ptrsize=8?"uptr":"uint",p)
}
deleteobject(o){
dllcall("DeleteObject",a_ptrsize=8?"uptr":"uint",o)
}
deletedc(h){
dllcall("DeleteDC",a_ptrsize=8?"uptr":"uint",h)
}
gdip_deletegraphics(p){
dllcall("gdiplus\GdipDeleteGraphics",a_ptrsize=8?"uptr":"uint",p)
}
gdip_graphicsfromimage(b){
dllcall("gdiplus\GdipGetImageGraphicsContext",a_ptrsize=8?"uptr":"uint",b,a_ptrsize=8?"uptrp":"uintp",g)
return g
}
gdip_createhiconfrombitmap(b){
dllcall("gdiplus\GdipCreateHICONFromBitmap",a_ptrsize=8?"uptr":"uint",b,a_ptrsize=8?"uptrp":"uintp",g)
return g
}
destroyicon(i){
dllcall("DestroyIcon",a_ptrsize=8?"uptr":"uint",i)
}
gdip_createbitmap(w,h){
dllcall("gdiplus\GdipCreateBitmapFromScan0",int,w,int,h,int,0,int,2498570,a_ptrsize=8?"uptr":"uint",0,a_ptrsize=8?"uptrp":"uintp",b)
return b
}
getdc(){
return dllcall("GetDC",a_ptrsize=8?"uptr":"uint",0)
}
releasedc(c){
r:=a_ptrsize=8?"uptr":"uint"
dllcall("ReleaseDC",r,0,r,c)
}
gdip_getimagewidth(b){
dllcall("gdiplus\GdipGetImageWidth",a_ptrsize=8?"uptr":"uint",b,uintp,w)
return w
}
gdip_getimageheight(b){
dllcall("gdiplus\GdipGetImageHeight",a_ptrsize=8?"uptr":"uint",b,uintp,h)
return h
}
gdip_getimagedimensions(b,byref w, byref h){
p:=a_ptrsize=8?"uptr":"uint"
dllcall("gdiplus\GdipGetImageWidth",p,b,uintp,w)
dllcall("gdiplus\GdipGetImageHeight",p,b,uintp,h)
}
gdip_clonebitmaparea(b,x,y,w,h){
dllcall("gdiplus\GdipCloneBitmapArea",float,x,float,y,float,w,float,h,int,2498570,a_ptrsize=8?"uptr":"uint",b,a_ptrsize=8?"uptrp":"uintp",d)
return d
}

loadfromfile(filename){
	global loadedimg
	if(!loadedimg[filename]){
		tmp:=gdip_createbitmapfromfile(filename)
		gdip_getimagedimensions(tmp,w,h)
		tmp2:=gdip_createbitmap(w,h)
		g:=gdip_graphicsfromimage(tmp2)
		gdip_drawimage(g,tmp,0,0,w,h,0,0,w,h)
		gdip_deletegraphics(g)
		gdip_disposeimage(tmp)
		loadedimg[filename]:=tmp2
	}
	return loadedimg[filename]
}

loadimage(num){
	global loadedimg
	if(!loadedimg[num]){
		loadedimg[num]:=loadimage2(num)
	}
	return loadedimg[num]
}
loadimage2(num){
	if(num="eevee"){
; Eevee
i:="iVBORw0KGgoAAAANSUhEUgAAANMAAAB2BAMAAACg+Lu3AAAAIVBMVEUAAACgYEjQmEhQMCBwSEgAAADgwJC4mHj44Kj4+PjMRRuaD3m1AAAAAXRSTlMAQObYZgAACnRJREFUeAGclMFyozoQRdsjs0+LsI/a8d5CsMgugNgrwfqymQ9+3Y1jzygzFPVOFZWLCu6hJVdgkwQlFazEYj2+w360p6CBksPNPvZTvzpyltCeYBdFzwOXoODHaj+29QmzhNFPEjxdoCDGCCVlzwP6rjqDMJAji4kDOyX4sRjrOBJtTErnopeabyqndu6x5BoJjiT4xV0KE2K9oXKpUJ2hgHRQY4nUIMFqyD6x4P1uclMYyj0JFzBhbdYeE3RNIHGXqkZUJHB8hPlas+F0XN9sXQi+3BJT174dtduqyvtQv55EftAPf/CkX6MqT0SeMK0qCfXS8Lprg07t+hCeU6mKA3okegK02tNFrDk6OCCrMINwETOrrNQCmF9Ep58c707o8iAnZ12T+G+TlyFDqeLqwNUvh5sqxKEWN6AIEbNUI1/0AvljVVVsaHqOdyf4fIGjJedcAwdaTSV9jNMVyeVbj7nG2A+WmpyXFpkzhG54gpZeTOytwxmg50fr7DD16uQA1ZzgSIJ0dFialJxTlXPuYv8p7wDfQGaWLk7BI86mRk4i7yLfyyZ/Er1+uObm1BO9AngS1g7YoIqzQUy/LbB+NgHPJsa5HeUQcjd5eaa1I8mxPJz6Xy1YopN12rGtmsBj8+fASS7TxaQGgCVOHX79xvECRp0clDe+eWtVvM11SmZVlfQZAjZfow8s9bElrEH3TIOyWHLL5x5VZNXzP6Y3Oa0P9eBZZTxiLSum8xqUzKp+j2rpktZsUiWopNoEdT+CxJmIZos7ptqjEjL8HeNeiRztqJAfaDck+N8YUnBfxX/tmsGS27gRhjmBeB9IpHWNqNGdJCDnOjJBJbUnyBSSc2oc0tcp11L7BF69x97ylEE32TDEEjeyOOtL0lXmtEaq/tgNmf03MPl8AirInwqb1rB1jGc2wdjcknga/AgTnPNt8N12SyVnz0PW1twRPPbrOvIxbIX3WDiqlh70tXugVuibsaa/V5sl+rqUevDugVohWWhOp1P78zjLCziilpKN/wZFcq3Qkf5+slbXP/tRi6uozZha8uWM7VsONfgv+4+6sUnVdeMv4D69hvKXJyEUSSmqn/dGdokKazLto75cQXkBoR84MEop9ggc1DYOlSPKfe69Q3nRZ+3LCIoixoeE66yTZNyGjxm3Pu+0jb5ExX3QX74Syou+b71yZq40q+eAIgrohcB9eHzgBnpQ9mhT4jw23yr20WI91OdzYzHt2UfN7G881GNfswzEUBdR2KAauZxHpsy4RXFt3yiPFb9E5Q5Vn9vzuW7OXxuHmu0vURzLZDQEhIghXycJ9GPo/4f5QmrBy+6NlShZFmmvFdokexRrvv5yPp8/fT67b7v4y8XKoUx6+DOTFgXRuSnn66eVMQFyD8kaMMgN54n09AdLni6+gX/99bNFWV6butCnuv1WzhxQHxNhmELVzQOTJwACVBKzJLFyAt6xqitP1nBDI63w/a/nDnXSVC++bJYOxeyywiW1lI0FQ+VzGgHDBMN3iXxEbmpRI62QfYKs6r997evHdpzzV97gBzDARlvUGlUfxiYUvptrFsWdDAjXmyDbVSoebYVib0mfPn/q70VaFMBiF8yPDeEA7Hdlo0EG9LdiIPfRVjhr61rvKWupOFrpt/hspz09a/MYlwHwifFW+L7+l3u+MtWj0tFYGO1OY+8pLqJ2hLrT9GjDh/g+qksr0veSHuIbGz6glCUV95KgC483fD/zUHW2vRs1T0Yb/kB/yA51f/2gC480/IEGOt6ZFEu91jjS8Af6I5RA+v6kMm5xWcB9VDaOwlSNvIfEOH+0obnfhcdnX7od0IT3oIzVG7w01IXHZ1+SOndaxvH5b6oCuvDI7EvCBDOfgNLQvYKjqsAdmX0zFCaoPyagMh3kibYo7VCsfBrMvp0wKQ0W4V4LTff8PxYeapUMZt9ef6SBoCff/bhQlQHIGNIWv3lfdmBzjfqjEyzTLCxKlCDU8P+du4aPbFQLQndrO9GM9towm4uLhv+xQ20D2iqYThtr+J54QI0w3UYbPomHW7YK5O8P2cXb7Uewp98lebv2ky1bo1pQ1r1yuGI3H9+MxKI1JpY/D0lJCs0pekOUXD2zeQrJUc1sOgBZpZCUeDvUQ9WjkpRWx3oA4dpeF5l+M5Q0FnVYu1Mblaw4Vm5R2utKvCFKAKpaBNlhE3R1izCdQsYg+YR6O9TW8GdmdoGseFe3Iou7dEqoHwBvsOJm1DYLLC5FhMg0MMQOfmwP5U2oPS102qPFNVQF7e4QsC0g8oUQkFRSSZwmDQBvQX3pUS/96+YKqzoCStt/4Ky2FQRnC3OAHxsT3YjqEbMm7Qd/cAZ2zIIg3NqwMSQVm0MMKxZXULjZ5njbUs1oS2TfdswZzN1DO6RQRUgP1sYY7G5zSAq+gFLfhjpBZETVaY8C+ABFM8QREKI/gRIlXB/YRVJqvH51h5rRhgU4L6Oo8GLn/lo2H9Li+nwHgZvUJ+zBSe/YGO4tX6y3V3d6IXCdotOQ07av+m7UDDSZubLTy05t0yLBbvksG42of7ZuyP/+k/9dkszhjHu4y8oy3r6+gz0RxpcN7ljMTu3rcgyVr9P/hvpA+4CDKSeDHREkZOBwYC47Z2Cq6KamNb0GGzmQANRwymE72hNhHAwIktOUTwyB+SQCUMUq7foiBFyPH+nEwylHOlTmUJlDuYIsbPgsAhaLKwjCPvBCSJ4iVKnna6dHgylHuu0X2aMoUeVQLOLcsliccXuN4Mk+yxeVEDuAClwaDxaukmQOqMsph3Z6opT1zGKIwgYseQEQCUsKT/b5ylQCJoGHgnOp1DxJIwnZEWqNKH/KoZ0epVnnRGWfaOShmLEsbSHwNM/wrww2ZisjA0v+ZIQQ2SJI0BScQH9INnBe3U85UuOUwxSyVIFQAAAKnUJ7umJrJHYMvFaPsMZwt2Al5Gfj/slASW0l3aY3g8xw9GAZBxSYBZCnA0m/8oUZqu+sNMhNQRDTHDDb8UgZ6GUdK82Tn3JADUcPjIsZyAFqG/is4zNeU7iqwezRU9XWouTCJvPTb3DYPRw9ji4DSQBGzMGJr7uOKHxTKbvUKShuPOwejh6MkkIPAYwS/V6j/Oiwezh6GKmK7pWkqskpm2d0xj1yKz2/UlvdO+D9kRYaTQ54/9v2fyt+HGqf/jjUlx+VoWpf/tAM9TdS44lmVb89ivSMUCCjqfVYrIeaTcX6RxdM8BZR4Aq5r3uUEJDh1GL60pZJzpfA0tbdcY7iHai7SCjKcKrNk5hEYHuC+FJZ6glRTCgO2HY6yunNTiS9Lm38TqS1DaCEIuwUlNObHorDeWmHWr52CSJ2Ksr/AwKISeelrHdt+FB12Mko/w8ICMVLUDOYYfOOUJbVTEGB3nTSFlC7Aep1EXxDvUwADTbwj3SImQJK9VRCvWuno9wGfqW6qEojCtPSiAJ3ySfVj624VZqAQqhT0RAfAbF1qa5qAmp4VhCSdkYUua6Y5RTSULBDBXvBia7aOnfHCz2FNBTsoVBFv8EfHgGq0ZV0BxNsINhJZJPMpOBGKCUmkm49KzCE/Q/QfMmBz9n9lgAAAABJRU5ErkJggg=="
	}else if(num="femaleeevee"){
; Female Eevee
i:="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"
	}else if(num="vulpix"){
; Vulpix
i:="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"
	}else if(num="fluffyvulpix"){
; FluffyVulpix
i:="iVBORw0KGgoAAAANSUhEUgAAAM0AAABrCAMAAADjJ/aoAAAAP1BMVEUAAADYcCi4cFjgkGgQEBBwIACAUDBYMADxqz7/0j342JCveD2gcEC4SCj/31lAZIf44LDwuHjGfWFok7/4+PigVZHIAAAAAXRSTlMAQObYZgAACdFJREFUeAHM09G2myAQhWHWuAEVj8np6fs/a0dGspHKMnH1on/bGyOMn1hXN45jcmd592GDdeN+VBfd7VJK4zRNY9JcE8QXj9eAw2/V40i+ZSiJwF3HFSLiILzg72JUYphJazmieUtkmwpUmnY8n62jQeOPMfL+ej9v993AqKRg+L0RMxwTUHMY/+KI9DVHf1z0j2hFI9zu1lG7LBmVkb+1o0ZqTcuBbDUaYTjVHPwxhECNcXweiKuj7qQSpex/Dxoh5tBBA44np6dB4wc1KD/br+gfdTfvvXGyKIM4l5gmAW9BmYlyocPhEk9/PhwcNcjbueujPtt94yRl2H8axXxtlY2G01BjqHEARIALDbgihHI6fEHYrIJd9pEmiihl2huT92WQfz5p6Wn8S1OGxSABwJsaKCVo9eoIn7fbPZ9qxlVPZVrXaUpJARJjNM0JhxqEYJhWoyE/Vjufi7gC2K4Brl5tJuegCfA+J0ZJ6zrqv1Utv7JFN2w15ZPjvghbeL3RUGnwQp1oAui3zEJNiMtS7SfQ3j2ctDmyZdCyZcnr5uc8E8F2TAy1gLBds/QwAfSzmhNVs9QbwhbAXYakkMnORTHBe28a5ajmpHluNDo8cng0zLK00+tF9LdBMxPoA9/OlUYlZlGM98OA8hw1Z65Cmcp58TUcAFE9Df2duHn9fq45X0OhaPY5c9X8dxzDKMsR1buR/uvq93Ot+f7+3ggYLEG9ClTsuX/Sja2AdzF4PB47h5gceoqouf8rAGoZ8Pvx82MaEVHNdcjfyocmuFwZ5LpB7mHioD0U85A/1JphjxQhEAUj20BinPj//63H9Om+g6lAbCLxfd3xNuUmzdRr/Et4rI80xX60N3rw1JkOpORcHhvetEWDlpKr+fP2k2EynLr3eGonXamW/MkMXww6APqib9rr3qZ/TTwiDyYNNLUUZyr5jqXJVw42pvqSrKNJ8iCDa3LqWYZHG98DjznNJ87LIzSMY28d+J71bamDSf6hfzd4G+KkzwwwLXkEsoZhTvNapFF/MdQXSx59l1v0tpxTdfljGP8/yh2SNRSrpeXvaAZTVRh9CsCBh2A6+UxJGyhl8qfmNGpjg74ojJm8ZrO3gU6bKQubtDRQEh8C+gdg9qqNqal2MFl8rmXd2zCZWwHuGDw0gzobc6NzqGR/bC7lwYBWvY2bWzJpxtHADFIb+7QC0VRRwJpUgNa9jZrbzCY9p8EZpDamlvrkPwMNexs3t0oT+HFgBomNFfW6uf+wt82bWzXp1FPZfA5DTShMo6Sy/6x7Gza3atLrNKszCCVMsdb/CTe3iqNZpeEZRFBxb+PmVnGUaG3gwwyKJ9Dcikl71mBgBsGJsDnY3Mqv6kSaVRpo1mCXFw83txLz2DIMjCA4ETaGm9sx67UNjyA+EeLh5jYehVo7EeLh5jYemKF4IsQDzS20HKPfdA/llRnanQg+Q+Ph5hbuC5DfvEub14PhqPLXhqMngs7QeLzs9GhzC/cFxnfO+4PkTO1j8DU4EWSGbocZm1vcsFfPjeLAL89E1+rXE4FmaKC59R7jqblNLU9+c7ecpQiTFh2sa9adCJEZCs1tbT+3lJ3QcuiP4y2nM31EPht1zUy/U0+E6AyF5tZMYKDlkJg2t19h0qOu2cOJADOUE2huJ/cFvOx0phvHK7cE9vneOl96IugMjYeb2/l9AS07y1219b5mQlOK/R47jgIzNBRsbqEXUCUwq9WZqj00u3cGHJ+hssvbCMPN7fN9gdFvnIniSA7jj12NRXZ5OkPj4eYW7wuAEmCqNeJSnOY17PI2wkBzC/cFwG/W1MN/K9nlAczOAI7upmPnm+7yfIbuDXv642WBwL3bajBDd4Y93RRkjjJf6mWYofvCns73BdYLdW50t8PEPd3SQqGuybnW/TBxT4fVPjTQMEM3J+bp42pfcf7d+OXmdh5e7XsMaA43txxY7XuKmUFjG0+gueXAar/eGyXfnh2h4eaWw6t9a3GmRZgTza0GVvuB63QHm1tY7QdyvLml1f7RcHPL4dX+6XBzy+HV/unwnVsOr/YPh+/ccni1/3/euT0/i+N3bs8nfuf2fOLN7bnk68qzZ8bXYm5uT+a6vn0k/yrVjFYcCUIoSoOHebr//7tLkLo6ukkFRsjDktOlx6ruCW7fGfFfnZ+f+9Sh2iV9aJ2BGwFvED0Z89svGYA5uZ0hXtfizj3wubV3YiCz0EfxtnOYIRGNc/rzWcYXVzImIzA6iLmYkdid9ZexOrcZlIh0nzrsfvVK2P2CAraOgOxHxVyEdvnu3GbWQvfQvNg5JqJZ60QUY43RESqR/oOBmVkP371hBXXF0yNuvs/ynYDkRWiVsjtnXTMyY+Q+ucX98sUn2DZciFFk2ZAXo1xlLhSdSWQw4ovJbe/XqEgsmU0Y2US3qQqXTQbFILODuE5uZ4ZaRK6VuXusZxZaBACi2yg/kk83QPalGCQJTpdx626TW6geUDKzr7hCEwD9HGVKbHOKtI0bL0nqKeGR0kY6NoJxtMVlckvS6AXr2AgA+eptk6lEEbZh3l9NR0iUjCGRfUFaiLx74vPkFjfa17thgti3FkUkNIind3QyElI4lSH3xTZJjN0Tnye3PsyjYaMMP4r27iuN67jKxLp7kXXQgIiGUETfPS6TWw4YWimsg58zW9jM0VEngGM8Oo+GsSgkkksXB4rPk1vfd/nZXY16GKEhDLgMNM8r9dG2QeqrlE2kTWYLnhZwn9yi2bCRw/uHurA/UiQDTzGoHhjTJoR6Nn7bkIAipKcXw31yWylO92eOLFnUeRe1g5L6iWXaSEnMWhWycB4Qbw2QLtIvYe6TW+vgjvUcedSkdpylspG6jY9R/pCngG7DkZFOJkMhBYhk1IRtc5ncbpuZA6QEDuOHgpH8F4mZ07KJ8I3urW6QFIAqykZcJ7fumMIteypHNxZRVT5C+NeAjYWibJKhZco0VS4AzpQh1AP/Fr+/c2ubbGmMJIbQhM4TrZBkxGDGBIHukn13S8xEROBIOq7v3LpjCiTFSGJoHXnWD1Mrlw2JFJPhhmn86RyIzve54v2dW9vUAagkwshUPowkMZSDKSPF6rxrXZm2zSMiru/c9mC4uKfTBssA20ZhqDHxplgBfYMdEeo63N+53f2IqCTaNiUj5TOPDpmyjJltkzHW2D4Ava9fT26J4JIE3xPr+WubI5NdGYy5V3gJJ1o+rEq+n9x67SpiI8QFuhl3pWkzCVQ298nttiHCe0QshKxABRXjSOOkerErdqIRU/c6uZ0HoC0Sb5WT4l0dx/j6/1gz0V13T27vsQt1SBFDfke6/C1R0yH+9r7Yh45+U6Xb/ZdE/r6IfwyjyY+cGOOUAAAAAElFTkSuQmCC"
	}else if(num="zorua"){
; Zorua
i:="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"
	}else if(num="pikachu"){
; Pikachu
i:="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"
	}else if(num="femalepikachu"){
; Female Pikachu
i:="iVBORw0KGgoAAAANSUhEUgAAAJcAAABxCAMAAADvXMHUAAAAJ1BMVEUAAABcKwP0vxbZkgAAAACXTwDy5k/FIRkdHR1OTVTmWkL4+Pj9+KB+kbIaAAAAAXRSTlMAQObYZgAABnBJREFUeF7lmuFy4zYMhL0LgLJzff/nLYUTjdI4mebpFHXanUx+8BPDT8pkzA1186jednIGi5jZO6x3/U4WViwFb7zudz2dZSkrNe+8NLzOZiHF4uG1XlkqaeWAgu9jZiVS3nu9aqvnHGZCz1AM0nkBqvfH43HXc5gx8lYMZHgBLHK/P+53PYmBfd55mQeA+i3I3bXOYRCSAkA9etsLrPxVUwqleApF9URGAW7jVC1PaSH0TAahfqLFn14hpaewiJLA2KuUZqXVC5pZC/TgvBAbeqk+6FJ8KFev3rkLjs2b+kWa/jD3sh9aNYh9LeLQvNASUR17PTavh3sRwazYxsyKswPzIioiY6+H0r2oD754wcrGqpqz4/NU1Qx6G8WWUp6f719fJM5lqPlkK4uliFQlca2vhTiX3cJq4EWhmRT3WhZCP2VLzTS7NatRYHymaoXXmC1fywSbDUyEEernbJlgOea5XZysxEHx+OYK6Upph395hTTLnwXXV6K2v29eYy39Jmb08IPHhdXruxjY8kmBVM2d6hwGSbVjUNRSpzqHgYI1cRODopY61Sksbwuv72mD/f11PS3E/lU9LYraVE/TuS42Py/v78c9jQ/lsG8dnxf7+7FX9JpB3zo6L+/vx/3RHjt9K3oNDs7L+/txf4xek72i1xyZl/f34/6402uKJXZ0Xuzvx/3R/tldiK4HJnZg3kywVKfoPOE1ZkvNBJv1orQ9h3cXQj9ltfPMsIj1GfY0D/Rjtsyx0Cpd8FFPo57DIiYc7PGvibFmoHXFQR8GJwtXHfRhsMO/6qAPjITY9Qd9EKqiRllzvVdAAlGSrj/oG2yksxfxXWyiEUFInM6mNtLR9c5m8xtpSHQ9j245hWmNATrVH1lqKPfW2U9gm+XsOZ9HvLOfxKBjq9z1PKxWGs6ZHZkXUsM+1BXjUijQ6IGZHZg3Ee81W7QUxHNOPdDZsXmeqT7Eh2p049xrnB2fFxn3oejNO+diHmeH5uWMz9PiHDGzOEecn3fES/renFkFlpmkeYmleXM9zdwtdeMBW2om2FzANSaldWPox6x2xGk2Tu6I6axwxJYJduScr2rxpqew/15U9Y8xsIvOj0ZPSEXhADN2Vcw0DNJouvY8LVDoERLxQWRMo3Gtp422QJLWEabcFIzUziCPKi3ZtoCUpHWAVReU4t9sNWAzKHm0XVs2W+p55UL988e/aamhaRjkUetsTUPrWUK7jvDbDKxO/kU3KQiDfrRdG7YF4dWffUV/+F0GlNK+XgzyKCrubVMfSv3h95ixwIWwCRCmddQN0qhf5bYx2ncXjY5wn2HlhRlZIqwxWQ0I5NF2LRCjrT+s2c6fGGdyeyy6RWh1DGQzY4vOjG79oVrF+VOUzl2WO0/PIEzRqdGa/n286Agjhu5dvZ5lBdGp0fw+HsJql+V39ZxF1EQMa0SawMToWe/qKZ+n2agxMcyN1tjOO3dHmK4JSxpFZ0abV4mzqVevpWaaRUJzdhQskf7oy1ntDxPszwXyFKMH2rNlgh3I8DwNepzlnPje45j9LzP+jWScOTxISANlNhJ7f0XF3Zop6hcYYES66YxaMBAjCeg7TANsX42kGbYW8StktqJXCyHf3S9ZaLB3vBRf1ojdC7xcJC+3KubbkA1F4n7j8YmvBUjx0JfdXTW2l9j1Mr+MyavAyq+94n4R/0tC6WKlIH5od4j+vMD2vFbua2evqss9r7hfVgRfU0B2Yt2ygIgQgLhYhLteyF6+NFhsZ+7L/QJQFQGQ3Sp2LmJmK6Rn5x+6K3p6uTdFG2ozrRgdUW8wYeRlYY+rCQB5fRxwEzxNwozRao19fBeLlevNTGrYYqS4FqsyOlbWv4j0LKGv4ozfM9oou0hruBBPENAKICtFhyBRLkKM2SviYulxqAceCLtARTYzEYGrNgTStZwZ2SBIc62NhXL7i0hHlyqpAHRpYsFNRPh8idd92KKqsTjYIITmxAMLZ1rx5IXRm+GWAkQ/EF0jtlVZwlWdCOIjw+EmLTXdQZJtzmYGGptWeCWzhnPgUVVblZTuVYq425b0biXWRR33wEgB/VEB9mYr1x6IiD+Kt3Fx3bywuunuO5/eQBOG+B2xQFhjwt0TQZX2PCSWGQW+cMF7XDST5gy4lOweCT51EF7jQN3tDU48OfcVKT/ZWa9wm+AD5xQ0Z9DO2bOPnceCV+VvKQOEiVr7JjQAAAAASUVORK5CYII="
	}else if(num="girlyeevee"){
; Girly Eevee
i:="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"
	}else if(num="possessedeevee"){
; Possessed Eevee
i:="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"
	}else if(num="facelesseevee"){
; Faceless Eevee
i:="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"
	}else if(num="chocoeevee"){
; Choco Eevee
i:="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"
	}else if(num="girlyvulpix"){
; Girly Vulpix
i:="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"
	}else if(num="possessedvulpix"){
; Possessed Vulpix
i:="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"
	}else if(num="alolanvulpix"){
; Alolan Vulpix
i:="iVBORw0KGgoAAAANSUhEUgAAAM0AAABrCAMAAADjJ/aoAAAAIVBMVEUAAACmydYQEBDa5vXE3uX///9RfKSFk7x2w9zA4e74+Pi7cckcAAAAAXRSTlMAQObYZgAACD5JREFUeF7Vmotu4zoMREvKTrr3/z/4JnrkhCGUqat2jR0gu0U9lngklYpofzzLbvpAyD8Oam866o9dcfth3Thsvwkg5LsPHq8K10I41Y38ayyotefibqE7ie1diae23FQNwNWOY/eaxl/43R3/c3vefN+AgcZKsReYLIcmdg/OnCby+7ZtDk0ldDU4mqbc1P4zAQNOo4BG9R+nM9M0kFWaUqwgCyyaxqHRk+PwQ4O7XfbJVEu5+40myOh3KroiCO8kA+ceZ6Z55QeHhjrygcmhdX+l6ZnLFY3nn9x939wby5wG/m0bONXb4Bwm90M0l5qXAwodCppHwN4ngng80XB1d+71O04no83WXOc5RmM7fzdmIyFrGmDgghFUhJPLXpede7i+DddNfar2OgpKF9srTeXpLJfLRdP4NqchXBSuRljH10Fie+7O7Ov0bJXHbLBc6n0SBoIM5lOYTJMdcaRoT9M0WfvBL2ZWacARNJDJqfFN0bTVlScbGoFjd5QO5fcfOs0cx0evHoMc0QA1oQFrJho/Njlep6WrQlmFmeE8GBBkCFs2Sprc1Ndpqkjsdr3TcBUKgj4uza+hvgrj1+vVB0zIhD6jSGTna+yV/10/P/U2lXPPQSaP6/fdGH8H5nK5VprPz88/B2DSxkC4SB4Hbjg78mjcj59i/XrtAH/mMK5oNu9D6WJI02nMM03+pq3PbdyV5a8eFzQ3Pc6mur8ZDTjDoc5NGidbazpTNBztNY5Ds3umARLfjEbjJJjJJuPfpdnV2XIgevytoBlr3V3AsN8EnKpjNNUuyghsgMCoyUEzGFgQRIFJ0SAfx5fdJ8eXzurpMOiahohgESdpePDmJLAjT5PD8YUoHUM7z0Eoz21aGUc1FubNkz+fxrwF7h5P0pwZuJNzm8KhcqtodGOahslpZMQtjgzi3CYqt4JGydVS28JRKMNkGvx+qHKbadYnJ5/GAow4/4hzm67cChoBMpkcmAKMOP/oydGV22/QyBykD2FgiVuWK7eaJucgfWb+xjnmQOUWHafJOQiaVS1Ubpv8CIxY5mJH0Fqp3LJkfpzGepHoINFK5RZ5FzArNHlHWJeu3GaJso1IQXJH0Fqo3K4LKLEjLEpXboUWyPKOsCpduUWui2iYfCWHaq1UbvP7AtPzzf4wzE445NBIE3PoOg2KlVuCepvT2gUOsZrG4CGH/hZMiHb+aM0DI7DvDziXS9wRyKHrIgYUOhfPb7YXJk3jcUdYz6G5cnutH2D0t85UT0N51t0nO8LP5lAqtz6pnUiarrc0+wYPO0LMoVorlVv9FDfTOIXogFOdHneEnEPX5RMYTRNxUjnUPbzVUa3sCDmHLkhXbjVNPOGDAk9VwhmE7iGHLkhUbjWN/HoQkaCJz/Joblm6cqtptECChmd5yzC6couWYDJTA+NZnoJZl8Zx96X9TTzLW5A8pwsUOQ55g1uY6MV3bvP7AofzpMskugqgK7fqfYHjNMh/EWb9nO67LKjn8fkFmPVzen60L2liDv15rZzT86N9cKD5K9KVW638aB+cbYPm9MqtVn60P7T93fqzrtwKTR/tbxx8TqCRlVsNwwCQ00+AEZVbofRof+F1uvMrt75t4cXzBZ1dueU9hTtN/eFs6cotkm8DnyRduT0Ocz6NfudW05wAs/DOLRKvNv/D79yenIvX37k9X+vv3J6v9crtaaJAIYRF4PjZLDUVaQ88AccjkhgLU0Nn2vHGUlnAOeq5s7iAYSzMcikkW7UDS4YBB+iZJ1sCztuxiA3lxY4VR24MWQaFhpGbevZk0VUHEOaRGLQ4Mm905EYCKq7oERYhSzC5DwzJgSU5SnQ8CMpk5MzwZItOjMxsplnnLeCYUdWz3BK4w1PwYFGVW2O8gAEn0QhHMBRoOoCVbsoN4ZkB68otY4GlsEwSTHJgyQ5oiBCaIMNjZUKjK7evPeDEZ+M3OBJvSQ67K9KU9imFJH5TawmP9WqMdQdDJyq3YTFHGHz2OnvWw4DX+mzZoHkECc0Y+Cq6rP+WTlPKoClGX9DMK7css0pfyqApFkPNNK2rYjigSakVnPKIwzCN37cwny0Ew1KZV25ZzNx/02NULTITqxEGDm4GJnpCqJgYF2gIhtkr9q5yy0INNJbCeKSi6eyzXGkk7yXEOjIbHsPy7AizJyq39jCW2AU41dRxAE6egRMc/IFnmu6hGSzdB8tYcqpy26ug/ZNHlWRkBeAUqpXX9Wp8SqJpsQKcaYxImT1dubUSBiz1wfxZXItMRveY7XiskDAyTe8UYGja5QG1PwObqtzSBZmEPqCJq7mwM9UrccVGGpJOiJXpYf46b0+n1RSATVZu84jlPqyHZKVAbIMFGkalzshuGALNgCmF6YPGzOqnCmBoJpVbRUMfnXPMHzs6lkpGOyPiTGN9FfFn+GzqU4OgKSYrt+ysDNlOH4alOlgkxdhiIS72TDM8oSeDpbJ1MEz1XsS3LPHOLTQEETsxPClSY9eDp8WKBws2WFqkDAmeoO7W79xCAwydWDZ1l6UhA5mVRp541mPASki+yVLG9daifOcWGhYAnQCTkIeHMYumCIOHkSdWeprQ8CVLvHOLDJauSaDAxNVIgh2m5MnBFjPScyQOOCbeuc2qLHSSAyVOThaYcBkweILK0OQ6PGZ83zxUubWbRCdmA4H/Ms0g3vfoyYvNSrieeQzcw5Vbcs20Ey5OTYIYmU1p4IFGV24zTciJNo0AEx6QIbaZB3A6ygJ3XrmVpXsCzQLTbBbHIFY1bToSuKJyK0SgSQWCeaCNZakjcHDkyu3yAxb70GK4lY49jvgfZteMvDOSec0AAAAASUVORK5CYII="
	}
	dllcall("Crypt32\CryptStringToBinary",ptr,&i,uint,0,uint,1,ptr,0,uintp,nsize,ptr,0,ptr,0)
	varsetcapacity(buffer,nsize,0)
	dllcall("Crypt32\CryptStringToBinary",ptr,&i,uint,0,uint,1,ptr,&buffer,uintp,nsize,ptr,0,ptr,0)
	hdata:=dllcall("GlobalAlloc",uint,2,uint,nsize)
	dllcall("RtlMoveMemory",uint,dllcall("GlobalLock",uint,hdata),uint,&buffer,uint,nsize)
	dllcall("GlobalUnlock",uint,hdata)
	dllcall("ole32\CreateStreamOnHGlobal",uint,hdata,int,1,uintp,pstream)
	dllcall("gdiplus\GdipCreateBitmapFromStream",uint,pstream,uintp,pbitmap)
	return pbitmap
}