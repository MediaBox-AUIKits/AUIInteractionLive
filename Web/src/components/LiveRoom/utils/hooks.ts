import { useRef, useEffect } from 'react';

export function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>();
  // Store current value in ref
  useEffect(() => {
    ref.current = value;
  }, [value]); // Only re-run if value changes

  // Return previous value (happens before update in useEffect above)
  return ref.current;
}

/**
 * 返回当前最新值的 Hook
 * @param value
 * @returns
 */
export function useLatest<T>(value: T) {
  const ref = useRef(value);
  ref.current = value;

  return ref;
}
