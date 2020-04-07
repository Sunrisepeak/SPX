#ifndef _ITERATOR_HPP
#define _ITERATOR_HPP

template<typename T>
class Iterator {
 public:
  virtual bool hasNext() = 0;
  virtual void next() = 0;

};

#endif