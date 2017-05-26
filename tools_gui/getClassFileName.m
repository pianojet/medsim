function classFile = getClassFileName(label)
  classData = getappdata(0, 'classData');
  conf = getappdata(0, 'conf');

  if (nargin < 1 && (~isfield(classData, 'classFocus') || classData.classFocus == 0))
    disp('no audio label set, cannot resolve path for classFile');
    classFile = '';
    return
  end

  if nargin < 1
    label = classData.classFocus;
  end

  classString = sprintf('%d', label);
  classFile = sprintf('%sapp_%s.mat', conf.classPath, classString);
