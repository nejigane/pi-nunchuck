var camera, scene, renderer;
var geometry, material, mesh;
var stats;
var ws, connected;

init();
animate();

function init() {
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000);
    camera.position.z = 1000;
    
    scene = new THREE.Scene();
    geometry = new THREE.CubeGeometry(200, 200, 200);
    material = new THREE.MeshBasicMaterial({ color: 0xff0000 });
    mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);

    renderer = new THREE.CanvasRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(renderer.domElement);

    stats = new Stats();
    stats.domElement.style.position = 'absolute';
    stats.domElement.style.top = '0px';
    stats.domElement.style.left = '0px';
    document.body.appendChild(stats.domElement);

    window.addEventListener('resize', onWindowResize, false);

    ws = new WebSocket('ws://10.0.1.66:8080/');
    ws.onerror = function (e){ console.log(e); }
    ws.onopen = function() { 
	connected = true;
    };
    ws.onmessage = function(event) {
	console.log(event);
    };
    connected = false;
}

function animate() {
    if (connected) ws.send('status');
    requestAnimationFrame(animate);
    renderer.render(scene, camera);
    stats.update();
}

function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}
