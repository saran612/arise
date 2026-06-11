import { useState, useEffect, useRef } from 'react'
import './App.css'

interface Goal {
  id: number;
  text: string;
  completed: boolean;
}

function App() {
  // --- Focus Timer State ---
  const [timerMode, setTimerMode] = useState<'focus' | 'shortBreak' | 'longBreak'>('focus');
  const [timeLeft, setTimeLeft] = useState(25 * 60);
  const [timerRunning, setTimerRunning] = useState(false);
  const intervalRef = useRef<number | null>(null);

  // Set time based on mode
  useEffect(() => {
    setTimerRunning(false);
    if (intervalRef.current) window.clearInterval(intervalRef.current);
    
    if (timerMode === 'focus') {
      setTimeLeft(25 * 60);
    } else if (timerMode === 'shortBreak') {
      setTimeLeft(5 * 60);
    } else if (timerMode === 'longBreak') {
      setTimeLeft(15 * 60);
    }
  }, [timerMode]);

  // Tick logic
  useEffect(() => {
    if (timerRunning) {
      intervalRef.current = window.setInterval(() => {
        setTimeLeft((prev) => {
          if (prev <= 1) {
            setTimerRunning(false);
            if (intervalRef.current) window.clearInterval(intervalRef.current);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    } else {
      if (intervalRef.current) window.clearInterval(intervalRef.current);
    }

    return () => {
      if (intervalRef.current) window.clearInterval(intervalRef.current);
    };
  }, [timerRunning]);

  const toggleTimer = () => {
    setTimerRunning(!timerRunning);
  };

  const resetTimer = () => {
    setTimerRunning(false);
    if (timerMode === 'focus') setTimeLeft(25 * 60);
    else if (timerMode === 'shortBreak') setTimeLeft(5 * 60);
    else if (timerMode === 'longBreak') setTimeLeft(15 * 60);
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  // --- Goals / Task State ---
  const [goals, setGoals] = useState<Goal[]>([
    { id: 1, text: 'Design landing page layout', completed: true },
    { id: 2, text: 'Implement Vite 3000 port configuration', completed: true },
    { id: 3, text: 'Implement interactive React components', completed: false },
  ]);
  const [newGoalText, setNewGoalText] = useState('');

  const addGoal = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newGoalText.trim()) return;
    setGoals([
      ...goals,
      {
        id: Date.now(),
        text: newGoalText.trim(),
        completed: false,
      },
    ]);
    setNewGoalText('');
  };

  const toggleGoal = (id: number) => {
    setGoals(goals.map((g) => (g.id === id ? { ...g, completed: !g.completed } : g)));
  };

  const deleteGoal = (id: number) => {
    setGoals(goals.filter((g) => g.id !== id));
  };

  return (
    <div className="glow-wrapper">
      {/* Background Decorative Glow */}
      <div className="hero-glow"></div>

      {/* Header */}
      <header className="header">
        <div className="container nav">
          <div className="logo" id="main-logo">
            <span>ARISE</span>
          </div>
          <ul className="nav-links">
            <li><a href="#features" className="nav-link">Features</a></li>
            <li><a href="#timer" className="nav-link">Focus App</a></li>
            <li><a href="#goals" className="nav-link">Planner</a></li>
          </ul>
        </div>
      </header>

      {/* Hero Section */}
      <section className="container hero">
        <h1 className="hero-title">
          Rise above the noise.<br />
          <span>Organize your focus.</span>
        </h1>
        <p className="hero-desc">
          Arise combines minimalism with highly efficient focus workflows. Schedule goals, run custom pomodoros, and build distraction-free environments right in your browser.
        </p>
        <div className="hero-ctas">
          <a href="#timer" className="btn btn-primary">Get Started</a>
          <a href="#features" className="btn btn-secondary">Learn More</a>
        </div>

        {/* Live Interactive Dashboard Preview */}
        <div className="preview-container">
          {/* Focus Timer Widget */}
          <div className="glass-card" id="timer">
            <div className="widget-title">
              <span>Focus Timer</span>
              <div style={{ display: 'flex', gap: '0.25rem' }}>
                <button 
                  className={`timer-mode-btn ${timerMode === 'focus' ? 'active' : ''}`}
                  onClick={() => setTimerMode('focus')}
                >
                  Focus
                </button>
                <button 
                  className={`timer-mode-btn ${timerMode === 'shortBreak' ? 'active' : ''}`}
                  onClick={() => setTimerMode('shortBreak')}
                >
                  Short
                </button>
                <button 
                  className={`timer-mode-btn ${timerMode === 'longBreak' ? 'active' : ''}`}
                  onClick={() => setTimerMode('longBreak')}
                >
                  Long
                </button>
              </div>
            </div>
            <div className="timer-display">
              {formatTime(timeLeft)}
            </div>
            <div className="timer-controls">
              <button onClick={toggleTimer} className="btn btn-primary" style={{ minWidth: '100px' }}>
                {timerRunning ? 'Pause' : 'Start'}
              </button>
              <button onClick={resetTimer} className="btn btn-secondary">
                Reset
              </button>
            </div>
          </div>

          {/* Goal Planner Widget */}
          <div className="glass-card" id="goals">
            <div className="widget-title">
              <span>Today's Focus Objectives</span>
              <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                {goals.filter(g => g.completed).length}/{goals.length} Completed
              </span>
            </div>
            <form onSubmit={addGoal} className="goal-input-wrapper">
              <input 
                type="text" 
                className="goal-input" 
                placeholder="What is your next goal?"
                value={newGoalText}
                onChange={(e) => setNewGoalText(e.target.value)}
              />
              <button type="submit" className="btn btn-primary" style={{ padding: '0.5rem 1rem' }}>
                +
              </button>
            </form>
            <ul className="goal-list">
              {goals.map((goal) => (
                <li key={goal.id} className="goal-item">
                  <div className="goal-left">
                    <div 
                      className={`goal-checkbox ${goal.completed ? 'completed' : ''}`}
                      onClick={() => toggleGoal(goal.id)}
                    >
                      {goal.completed && '✓'}
                    </div>
                    <span className={`goal-text ${goal.completed ? 'completed' : ''}`}>
                      {goal.text}
                    </span>
                  </div>
                  <button 
                    onClick={() => deleteGoal(goal.id)} 
                    className="goal-delete"
                    title="Delete Goal"
                  >
                    ✕
                  </button>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="features" id="features">
        <div className="container">
          <div className="section-hdr">
            <h2 className="section-title">Designed for Deep Work</h2>
            <p className="section-desc">Minimal interface, zero clutter, absolute efficiency.</p>
          </div>
          <div className="features-grid">
            <div className="glass-card feature-card">
              <div className="feature-icon-box">⏳</div>
              <h3 className="feature-name">Sleek Pomodoro</h3>
              <p className="feature-desc">Integrated timer with configurable intervals, designed to blend naturally with your workspace.</p>
            </div>
            <div className="glass-card feature-card">
              <div className="feature-icon-box">🎯</div>
              <h3 className="feature-name">Daily Target Alignment</h3>
              <p className="feature-desc">Establish up to 3 priority focus areas each day, keeping you aligned with what truly matters.</p>
            </div>
            <div className="glass-card feature-card">
              <div className="feature-icon-box">⚡</div>
              <h3 className="feature-name">Ambient Environments</h3>
              <p className="feature-desc">Configure soundscapes, dark mode gradients, and sensory-friendly layout modes.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="container footer-content">
          <div>
            <div className="logo">
              <span>ARISE</span>
            </div>
          </div>
          <div className="footer-copyright">
            &copy; {new Date().getFullYear()} Arise. All rights reserved.
          </div>
        </div>
      </footer>
    </div>
  )
}

export default App
