function make(varargin)

% Builds all mex files in the directory 

disp('zapping old mex files...');

flags = {};
%flags = {'-g'};

cd util;
delete(['*.',mexext]);
cd(getDrakePath());

cd systems/plants;
delete(['*.',mexext]);

cd @RigidBodyManipulator/private;
delete(['*.',mexext]);

cd ../../@PlanarRigidBodyManipulator/private;
delete(['*.',mexext]);

cd(getDrakePath());

if (nargin<1 || ~strcmp(varargin{1},'clean'))

disp('compiling mex files...');

%On Win64, John had to use the following lines (currently commented) and 
%comment out the lines beginning with mex to
%deal with an error in which the compiler could not find "simstruc.h"
%simulinkIncludeDir = ['-I"' matlabroot '\simulink\include"'];

load drake_config;

try 
  cd util;
  mex realtime.cpp
  cd(getDrakePath());

  if checkDependency('eigen3_enabled')
    eigenflags = {flags{:},['-I',conf.eigen3_incdir]};
    cd systems/plants/;

    mex('-c','Model.cpp',eigenflags{:});
    modelflags = {['Model.',objext],eigenflags{:}};
    mex('deleteModelmex.cpp',modelflags{:});
    mex('HandCmex.cpp',modelflags{:});
    mex('doKinematicsmex.cpp',modelflags{:});
    mex('forwardKinmex.cpp',modelflags{:});
    mex('inverseKinmex.cpp',modelflags{:});
    
    mex('deleteModelpmex.cpp',eigenflags{:});
    mex('HandCpmex.cpp',eigenflags{:});
    mex('doKinematicspmex.cpp',eigenflags{:});
    mex('forwardKinpmex.cpp',eigenflags{:});
    mex('forwardKinVelpmex.cpp',eigenflags{:});

    cd @RigidBodyManipulator/private;
    modelflags = {fullfile('..','..',['Model.',objext]),eigenflags{:}};
    mex('constructModelmex.cpp',modelflags{:});
    
    cd ../../@PlanarRigidBodyManipulator/private;
    mex('constructModelpmex.cpp',eigenflags{:});
    
    cd(getDrakePath());
  end

  cd systems;
  mex DCSFunction.cpp
  cd(getDrakePath());
catch ex
  cd(getDrakePath());
  rethrow(ex);
end

end

disp('done.');
