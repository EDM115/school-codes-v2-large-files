//!-- UTF8

/*
	Class: LoadingTail

	Queue de chargement pour médias de type xml et swf/jpg

	par Marc Loyat info@laforme.net <http://www.laforme.net>, le 06/06/2003

	Description:
		Hérite de *Array*

		Cette classe permet de créer une queue de chargement de fichiers pour ne pas les charger simultanément.
		Le chargement simultané de fichiers peut poser problème dans certains cas avec certains navigateurs, la queue
		de chargement évite ces problèmes.

	Utilisation:
		(code)
		monChemin = new LoadingTail ();
		(end)

	Paramètres:
		Aucun

	Retourne:
		une référence à l'objet

	Exemple:
		(code)
		myTail = new LoadingTail();
		myTail.autoLoad = true;
		(end)
*/
_global.LoadingTail = function () {
	super();
};
LoadingTail.prototype = new Array();
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
// PROPRIETES PUBLIQUES
// __________________________
/*
	Property: autoLoad

		Définit le lancement automatique du chargement

	Description:
		Booleen en lecture/ecriture qui définit si le chargement se lance automatiquement lorsque que vous insérez des éléments à charger.

		Si autoLoad est à false vous devrez lancer le chargement en invoquant la méthode <loadElements>.
*/
LoadingTail.prototype.autoLoad = false;
ASSetPropFlags (LoadingTail.prototype, "autoLoad", 3);
/*
	Property: loading

		Indicateur du chargement

	Description:
		Booleen en lecture seule qui indique si le chargement est en cours ou pas.

*/
LoadingTail.prototype.loading = false;
ASSetPropFlags (LoadingTail.prototype, "autoLoad", 7);

// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
// METHODES PRIVEES
// __________________________
LoadingTail.prototype.moteur = function (aTail) {
	// fonction de boucle de chargement
	// si la file est vide, arret du chargement
	if (aTail.length == 0) {aTail.stopLoading();}
	// s'il y'a encore des elements dans la file
	else {
		// definition d'une référence vers le premier élément la file
		var e=aTail[0];
		// si l'élément est en cours de chargement
		if (e.loading) {
			// définition de la valeur de loaded en fonction du type de l'élément
			if (e.type=="swf"
			&& e.cible.getBytesTotal()==e.cible.getBytesLoaded()
			&& e.cible.getBytesTotal()>10) {
				e.loaded = true;
			}
			else if (e.type=="xml" && e.cible.loaded==true) {e.loaded = true;}
			// si l'élément a fini de charger
			if (e.loaded==true) {
				// appel de la fonction onLoad
				e.onLoad.apply(e.cible, e.args);
				// suppression de l'élément de la file
				aTail.shift();
			}
		}
		// si l'élément n'est pas en cours cde chargement
		else {
			//trace ("chargement de "+e.url+" vers "+e.cible);
			// si le type de l'élément est swf
			if (e.type=="swf") {
				// chargement du swf vers la cible
				e.cible.loadMovie (e.url);
			}
			// si le type est xml
			else if (e.type=="xml") {
				// chargement du xml vers la cible
				e.cible.load (e.url);
			}
			// définition de la valeur de loading de l'élément
			e.loading = true;
		}
	}
};
ASSetPropFlags (LoadingTail.prototype, "moteur", 7);

//
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
// METHODES PUBLIQUES
// __________________________
//
/*
	Method: pushElement

	Ajoute un élément à charger dans la queue de chargement

	Utilisation:
		myTail.pushElement(aType, aUrl, aCible, aOnLoad, argsOnLoad);

	Paramètres:
		aType ("swf" | "xml") - type du medium à charger, le type swf comprend aussi le jpg
		aUrl (String) - URL du medium en relatif ou en absolu
		aCible (ref) - référence au clip cible du chargement
		aOnLoad (Function) - function exécutée, appliquée au clip cible à la fin du chargement
		argsOnLoad (Array) - tableau d'arguments à passer à la function aOnLoad à la fin du chargement

	Retourne:
		la nouvelle longueur du tableau

	Exemple:
		(code)
		myTail = new LoadingTail();
		myTail.autoLoad = true;
		myTail.pushElement ("xml", "toto.xml", this.createEmptyMovieClip("cible", 1), function(aStr){trace (aStr);}, ["toto"]);
		(end)
*/
LoadingTail.prototype.pushElement = function (aType, aUrl, aCible, aOnLoad, argsOnLoad) {
	this.push ({type:aType, url:aUrl, cible:aCible, onLoad:aOnLoad, loading:false, loaded:false, args:argsOnLoad});
	if (this.autoLoad && !this.loading) {
		this.loadElements();
	}
	return this.length;
};
ASSetPropFlags (LoadingTail.prototype, "pushElement", 1);
/*
	Method: loadElements

	Lance le chargement des media

	Utilisation:
		myTail.loadElements();

	Paramètres:
		Aucun

	Retourne:
		rien

	Exemple:
		(code)
		myTail = new LoadingTail();
		myTail.pushElement ("xml", "toto.xml", this.createEmptyMovieClip("cible", 1));
		myTail.loadElements();
		(end)
*/
LoadingTail.prototype.loadElements = function (){
	this.loading = true;
	this.si = setInterval (this.moteur, 10, this);
};
ASSetPropFlags (LoadingTail.prototype, "loadElements", 1);
/*
	Method: stopLoading

	Interromp le chargement

	Utilisation:
		myTail.stopLoading();

	Paramètres:
		Aucun

	Retourne:
		rien

	Exemple:
		(code)
		myTail = new LoadingTail();
		myTail.pushElement ("xml", "toto.xml", this.createEmptyMovieClip("cible", 1));
		myTail.loadElements();
		myTail.stopLoading();
		(end)
*/
LoadingTail.prototype.stopLoading = function () {
	this.loading = false;
	clearInterval (this.si);
};
ASSetPropFlags (LoadingTail.prototype, "stopLoading", 1);
/*
	Method: clear

	Arete le chargement et réinitialise la queue

	Utilisation:
		myTail.clear();

	Paramètres:
		Aucun

	Retourne:
		rien

	Exemple:
		(code)
		myTail = new LoadingTail();
		myTail.autoLoad = true;
		myTail.pushElement ("xml", "toto.xml", this.createEmptyMovieClip("cible", 1));
		myTail.clear();
		(end)
*/
LoadingTail.prototype.clear = function () {
	this.stopLoading ();
	this.splice(0, this.length);
};
ASSetPropFlags (LoadingTail.prototype, "clear", 1);