let project = new Project('Git Gold');
project.addAssets('Assets/**');
project.addSources('Sources');
project.addLibrary('Echoes');
project.addLibrary('hxbit');
project.addLibrary('slide');
project.addLibrary('nape-haxe4');
project.addLibrary('hxcpp-debug-server');
project.addLibrary('hxcpp');
project.addParameter('-dce no');
//project.addDefine('debug_collisions');
project.icon = 'Assets/icon.png';
project.windowOptions.width = 900;
project.windowOptions.height = 700;
resolve(project);
project.addParameter('--macro macros.Assets.addAssetList()');
