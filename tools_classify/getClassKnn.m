function c = getClassKnn(scores, topThreshold)
  % expect the predicted label to be last element
  % assumes classCount + 1 to be silence class
  % assumes classCount + 2 to be unknown class (if posterior below topThreshold)

  c = scores(1,end);