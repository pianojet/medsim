function classFile = getClassFileName(label)
  classData = getappdata(0, 'classData');
  conf = getappdata(0, 'conf');
  if (nargin < 1 && isempty(classData.classNumberList))
    disp('no audio label set, cannot resolve path for classFile');
    classFile = '';
    return
  end

  if nargin < 1
    label = classData.classNumberList(1);
  end

  classString = sprintf('%d', label);
  classFile = sprintf('%sapp_%s.mat', conf.classPath, classString);
