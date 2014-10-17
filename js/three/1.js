window.onload = function() {

    var renderer = new THREE.WebGLRenderer();
    renderer.setSize( 800, 600 );
    document.body.appendChild( renderer.domElement );

    var scene = new THREE.Scene();

    var camera = new THREE.PerspectiveCamera(
        35,             // Field of view
        800 / 600,      // Aspect ratio
        0.1,            // Near plane
        10000           // Far plane
    );
    camera.position.set( -15, 10, 10 );
    camera.lookAt( scene.position );

    var geometry = new THREE.CubeGeometry( 5, 5, 5 );
    var material = new THREE.MeshLambertMaterial( { color: 0xFFF000 } );
    var mesh = new THREE.Mesh( geometry, material );
    scene.add( mesh );

    var light = new THREE.PointLight( 0xFFFF00 );
    light.position.set( 10, 10, 10 );
    scene.add( light );

    var clock = new THREE.Clock(true);

    function render() {
        mesh.rotation.y = clock.getElapsedTime();

	    requestAnimationFrame(render);
	    renderer.render(scene, camera);
    }
    render();
};
