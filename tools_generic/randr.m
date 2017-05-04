function r = randr(varargin)
  %  Author: Justin Taylor, May 2017
  %  `randr`, or "random range" is a tool for quickly obtaining
  %   suitable random numbers within variety of types and ranges.
  %   It is designed to default to `rand` or `randi` when able,
  %   but supports the following functionality (which overrides
  %   certain functionality for `rand` or `randi`):
  %
  %  randr()                      Effectively executes `rand`, uniform (0,1)
  %
  %  randr(<number>, <number>)    Return a random number bounded by given
  %                               range, inclusive. Note: if one of the given
  %                               numbers in the range is real, the output
  %                               will be real.  If both are integers, the
  %                               output will be an integer.
  %
  %  randr(<cellarray>, <size>)   Returns a <size> unique (non-repeating)
  %                               cellarray of elements from given
  %                               <cellarray>.  This allows for selecting
  %                               random member(s) from almost any collection.
  %                               Optional: <size>, defaults to 1
  %
  %  randr(<string>, <size>)      Returns a random string of size <size> that
  %                               contains chars from <string>.  Note: <string>
  %                               can denote a category of characters from
  %                               which to draw for the string according to:
  %                                 'alpha': alphabet characters (upper & lower)
  %                                 'num': numerals
  %                                 'alphanum': alpha-numeric characters (upper & lower)
  %                                 'base64': a legal base64 encoding
  %                                           Note: no attention paid to decoded str
  %
  %                               Optional: <size>, defaults to 8
  %

  % no params, use `rand`
  if (length(varargin) == 0)
    r = rand();

  % generate random strings
  elseif ischar(varargin{1})
    n1_alpha = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    n1_num = '1234567890';
    n1 = varargin{1};
    strlen = 8;

    switch n1
      case 'alpha'
        n1 = n1_alpha;
      case 'num'
        n1 = n1_num;
      case 'alphanum'
        n1 = [n1_alpha n1_num];
      case 'base64'
        n1 = [n1_alpha n1_num '+/'];
    end

    if (length(varargin) > 1) && (length(n1) > 0) && (varargin{2} > 1)
      strlen = varargin{2};

      % ensure valid base64 str length
      if strcmp(varargin{1}, 'base64')
        maybeTrim = mod(strlen, 4);
        if strlen < 4
          strlen = 4;
        elseif maybeTrim > 0
          strlen = strlen - maybeTrim;
        end
      end
    end

    r = '';
    for i = 1:strlen
      idx = randi(length(n1));
      r = [r n1(idx)];
    end

    % add random paddings for base64
    if strcmp(varargin{1}, 'base64')
      paddingChance = randi(3);
      switch paddingChance
        case 1
          r(end) = '=';
        case 2
          r(end-1:end) = '==';
      end
    end

  % if given two numbers, return a random number within range (this overrides matrix output for `rand`/`randi`)
  elseif (length(varargin) == 2) && isnumeric(varargin{1}) && isnumeric(varargin{2})
    n1 = min(varargin{1}, varargin{2});
    n2 = max(varargin{1}, varargin{2});

    % defensive edge case
    if n1 == n2
      r = n1;

    % check if integers to generate random integer
    elseif (rem(n1,1) == 0) && (rem(n2,1) == 0)
      r = randi(n2-n1+1) + n1 - 1;

    % if one or both are real numbers, use the real number form
    else
      r = n1 + (n2-n1) .* rand();

    end

  % return a random cell, or multiple unique cells
  elseif iscell(varargin{1}) && length(varargin{1}) > 0
    n1 = varargin{1};

    if (length(varargin) > 1) && (length(n1) > 0) && (varargin{2} > 1)
      looping = varargin{2};
    else
      looping = 1;
    end

    if (looping >= length(n1))
      r = n1;
      return
    end

    r = {};
    for i = 1:looping
      idx = randi(length(n1));
      r{length(r)+1} = n1{idx};
      n1(idx) = [];
    end

  % default behavior with parameters, use randi
  else
    r = randi(varargin{:});

  end
