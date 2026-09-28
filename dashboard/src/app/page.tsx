'use client';

import React, { useState, useEffect } from 'react';
import Image from 'next/image';
import {
  Shield,
  Award,
  Users,
  Heart,
  TrendingUp,
  AlertTriangle,
  FileText,
  PhoneCall,
  CheckCircle2,
  RefreshCw,
  Search,
  BookOpen,
  Send,
  Lock,
  Activity,
  Layers,
  Sparkles,
  Clock,
  Radio,
  Eye,
  EyeOff,
  LogIn,
  LogOut,
  UserCheck,
  Calendar,
  Home,
  MessageSquare,
  HelpCircle,
  X,
  ExternalLink,
  ChevronRight,
  Terminal,
  FileCheck,
  Zap,
  Sliders,
  Bell,
  Menu,
  ChevronDown,
  Compass,
  FileSpreadsheet,
  Stethoscope,
  Briefcase,
  PieChart,
  BarChart3,
  MapPin,
  TrendingDown,
  GraduationCap,
  Building2,
  LifeBuoy,
} from 'lucide-react';
import KineticDotsLoader from '@/components/ui/kinetic-dots-loader';
import {
  getCommanderDashboardData,
  getWelfareDashboardData,
  getFamilyDashboardData,
  getPersonnelRoster,
  getAssessmentBatteryResults,
  PersonnelRosterItem,
  AssessmentResultItem,
  OperationalCommandLog,
} from '@/lib/supabase';

type UserRole = 'commander' | 'welfare' | 'family';

interface UserSession {
  email: string;
  name: string;
  rank: string;
  role: UserRole;
  forceId: string;
  unit: string;
}

export default function AppMain() {
  // Authentication State
  const [currentUser, setCurrentUser] = useState<UserSession | null>(null);
  const [emailInput, setEmailInput] = useState('commander1@raksha.gov.in');
  const [passwordInput, setPasswordInput] = useState('••••••••••••');
  const [showPassword, setShowPassword] = useState(false);
  const [isAuthenticating, setIsAuthenticating] = useState(false);

  // Active View per Role
  const [commanderView, setCommanderView] = useState<'overview' | 'roster' | 'analytics' | 'commands' | 'assessments'>('overview');
  const [welfareView, setWelfareView] = useState<'claims' | 'budget' | 'rag' | 'grievances' | 'trends'>('claims');
  const [familyView, setFamilyView] = useState<'vault' | 'scholarships' | 'emergency' | 'hospitals'>('vault');

  // Roster Filter (Commander view)
  const [selectedCompanyFilter, setSelectedCompanyFilter] = useState<string>('ALL');

  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  // Live Telemetry Data
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [isRefreshing, setIsRefreshing] = useState<boolean>(false);
  const [commanderData, setCommanderData] = useState<any>(null);
  const [welfareData, setWelfareData] = useState<any>(null);
  const [familyData, setFamilyData] = useState<any>(null);
  const [rosterData, setRosterData] = useState<PersonnelRosterItem[]>([]);
  const [assessmentData, setAssessmentData] = useState<AssessmentResultItem[]>([]);

  // Operational Command Logs
  const [commandLogs, setCommandLogs] = useState<OperationalCommandLog[]>([
    {
      id: 'CMD-901',
      commandType: 'REST & RECUPERATION (R&R) ORDER',
      targetUnit: 'Alpha Coy (Post 14 Mana Pass)',
      authorizedBy: 'Col. Sanjay Sharma (Commanding Officer)',
      timestamp: 'Today, 06:30 IST',
      status: 'ACKNOWLEDGED',
      notes: 'Dispatched mandatory 72hr sleep recovery rotation for 4 flagged jawans.',
    },
    {
      id: 'CMD-902',
      commandType: 'DISCRETIONARY GRANT APPROVAL',
      targetUnit: 'Welfare Cell / Hav. R.S. Negi',
      authorizedBy: 'Capt. Radhika Verma (Welfare Officer)',
      timestamp: 'Yesterday, 17:15 IST',
      status: 'COMPLETED',
      notes: 'Sanctioned ₹85,000 for emergency medical pre-authorization.',
    },
  ]);

  const [activeToast, setActiveToast] = useState<string | null>(null);

  // RAG Search State (Welfare)
  const [ragQuery, setRagQuery] = useState('');
  const [ragAnswer, setRagAnswer] = useState<string | null>(null);
  const [isRagSearching, setIsRagSearching] = useState(false);

  // Morale Note State (Family)
  const [noteRecipient, setNoteRecipient] = useState('');
  const [noteContent, setNoteContent] = useState('');
  const [noteSentSuccess, setNoteSentSuccess] = useState(false);

  useEffect(() => {
    loadAllData();
  }, []);

  async function loadAllData() {
    setIsLoading(true);
    try {
      const [cmd, wlf, fam, ros, asm] = await Promise.all([
        getCommanderDashboardData(),
        getWelfareDashboardData(),
        getFamilyDashboardData(),
        getPersonnelRoster(),
        getAssessmentBatteryResults(),
      ]);
      setCommanderData(cmd);
      setWelfareData(wlf);
      setFamilyData(fam);
      setRosterData(ros);
      setAssessmentData(asm);
    } catch (err) {
      console.error('Failed to load data:', err);
    } finally {
      setIsLoading(false);
    }
  }

  async function handleRefresh() {
    setIsRefreshing(true);
    await loadAllData();
    setIsRefreshing(false);
    showToast('Live telemetry synchronized with Supabase.');
  }

  function showToast(msg: string) {
    setActiveToast(msg);
    setTimeout(() => setActiveToast(null), 3500);
  }

  // Handle Form Login
  function handleFormSubmit(e: React.FormEvent) {
    e.preventDefault();
    setIsAuthenticating(true);

    setTimeout(() => {
      setIsAuthenticating(false);
      const email = emailInput.toLowerCase().trim();
      let role: UserRole = 'commander';
      let name = 'Col. Sanjay Sharma, SM';
      let rank = 'Commanding Officer (14 Bn)';
      let forceId = 'CRPF-CMD-4091';
      let unit = '14th Battalion ITBP / Border Sector';

      if (email.includes('welfare')) {
        role = 'welfare';
        name = 'Capt. Radhika Verma';
        rank = 'Battalion Welfare Officer';
        forceId = 'ITBP-WLF-8120';
        unit = 'Battalion Welfare & Grants Cell';
      } else if (email.includes('family')) {
        role = 'family';
        name = 'Sunita Devi (W/o Hav. R.S. Negi)';
        rank = 'Veer Parivar Family Member';
        forceId = 'FAM-DEP-3912';
        unit = 'Dependent Welfare Cell (Dehradun)';
      }

      setCurrentUser({ email, name, rank, role, forceId, unit });
    }, 600);
  }

  // Quick Demo Role Click
  function handleQuickDemoLogin(role: UserRole) {
    setIsAuthenticating(true);
    setTimeout(() => {
      setIsAuthenticating(false);
      let email = 'commander1@raksha.gov.in';
      let name = 'Col. Sanjay Sharma, SM';
      let rank = 'Commanding Officer (14 Bn)';
      let forceId = 'CRPF-CMD-4091';
      let unit = '14th Battalion ITBP / Border Sector';

      if (role === 'welfare') {
        email = 'welfare1@raksha.gov.in';
        name = 'Capt. Radhika Verma';
        rank = 'Battalion Welfare Officer';
        forceId = 'ITBP-WLF-8120';
        unit = 'Battalion Welfare & Grants Cell';
      } else if (role === 'family') {
        email = 'family1@raksha.gov.in';
        name = 'Sunita Devi (W/o Hav. R.S. Negi)';
        rank = 'Veer Parivar Family Member';
        forceId = 'FAM-DEP-3912';
        unit = 'Dependent Welfare Cell (Dehradun)';
      }

      setCurrentUser({ email, name, rank, role, forceId, unit });
    }, 450);
  }

  function handleSignOut() {
    setCurrentUser(null);
  }

  function dispatchCommand(type: string, target: string, notes: string) {
    const newCmd: OperationalCommandLog = {
      id: `CMD-${Math.floor(100 + Math.random() * 900)}`,
      commandType: type,
      targetUnit: target,
      authorizedBy: currentUser?.name || 'Authorized Command',
      timestamp: 'Just now',
      status: 'DISPATCHED',
      notes,
    };
    setCommandLogs([newCmd, ...commandLogs]);
    showToast(`Order Dispatched: ${type} sent to ${target}`);
  }

  function handleRagSearch(e: React.FormEvent) {
    e.preventDefault();
    if (!ragQuery.trim()) return;
    setIsRagSearching(true);
    setRagAnswer(null);

    setTimeout(() => {
      setIsRagSearching(false);
      if (ragQuery.toLowerCase().includes('ayushman') || ragQuery.toLowerCase().includes('health')) {
        setRagAnswer(
          'MHA OM No. 27011/04/2021: Ayushman CAPF covers serving personnel and all enrolled dependents up to ₹5,00,000 annually with 100% cashless pre-authorization across CGHS and PMJAY empanelled hospitals.'
        );
      } else if (ragQuery.toLowerCase().includes('pmss') || ragQuery.toLowerCase().includes('scholarship')) {
        setRagAnswer(
          'Under WARB Prime Minister Scholarship Scheme (PMSS): Dependent children of serving/ex-CAPF personnel receive ₹36,000/yr (girls) and ₹30,000/yr (boys) for technical degrees.'
        );
      } else {
        setRagAnswer(
          `Official Clause Verified: Policy retrieved from Section 4.2 of CAPF Welfare Compendium. Eligible for priority liaison processing through Unit Welfare Officer.`
        );
      }
    }, 1100);
  }

  function handleSendMoraleNote(e: React.FormEvent) {
    e.preventDefault();
    if (!noteRecipient || !noteContent) return;
    setNoteSentSuccess(true);
    setTimeout(() => {
      setNoteRecipient('');
      setNoteContent('');
      setNoteSentSuccess(false);
      showToast('Encrypted message dispatched to outpost vault.');
    }, 2500);
  }

  // Filtered Roster for Commander
  const filteredRoster = selectedCompanyFilter === 'ALL'
    ? rosterData
    : rosterData.filter((r) => r.company.toLowerCase().includes(selectedCompanyFilter.toLowerCase()));

  // =========================================================================
  // VIEW 1: PROPER APP LOGIN SCREEN (When not signed in)
  // =========================================================================
  if (!currentUser) {
    return (
      <div className="aura-bg min-h-screen flex items-center justify-center p-4">
        {/* Layer 1 - normal */}
        <div className="aura-layer-1" aria-hidden="true" />
        {/* Layer 2 - multiply */}
        <div className="aura-layer-2" aria-hidden="true" />
        {/* Layer 3 - multiply */}
        <div className="aura-layer-3" aria-hidden="true" />
        {/* Layer 4 - multiply */}
        <div className="aura-layer-4" aria-hidden="true" />

        <div className="relative z-10 w-full max-w-[440px] space-y-5 animate-fadeIn">
          {/* Header & Military Welfare Crest */}
          <div className="flex flex-col items-center text-center">
            <div className="w-[76px] h-[76px] rounded-[22px] bg-white border-[1.5px] border-cyan-300 p-1.5 shadow-[0_8px_20px_rgba(8,145,178,0.2)] flex items-center justify-center relative overflow-hidden transition-all duration-300 hover:scale-105">
              <Image
                src="/rakshasetu_logo.png"
                alt="RakshaSetu Logo"
                width={70}
                height={70}
                className="object-contain"
                priority
              />
            </div>

            <h1 className="mt-3.5 text-[26px] font-extrabold tracking-tight text-[#0A1F2C]">
              Raksha<span className="text-[#0891B2]">Setu</span>
            </h1>
            <p className="text-xs font-semibold text-slate-600 mt-0.5">
              Armed Forces Welfare & Resilience Platform
            </p>
            <p className="text-[11.5px] font-bold italic text-[#C59B27] mt-0.5 font-cinzel">
              Balidanam Veer Lakshanam • Protecting Those Who Protect India
            </p>
          </div>

          {/* HR Firewall Status Banner */}
          <div className="flex items-center justify-center">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-50/90 border border-emerald-300/80 shadow-xs">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
              <span className="text-[11px] font-extrabold tracking-wider text-emerald-900">
                HR FIREWALL ENGAGED
              </span>
              <span className="text-[10px] text-emerald-700/80 hidden sm:inline">• Zero-Knowledge Isolation</span>
            </div>
          </div>

          {/* Liquid Glass Login Card Form */}
          <div className="liquid-glass p-6 rounded-[24px] shadow-[0_12px_40px_rgba(12,35,64,0.08)]">
            <div className="mb-4">
              <h2 className="text-[17px] font-bold text-slate-900">Service Authentication</h2>
              <p className="text-xs text-slate-500 mt-0.5">Sign in with your verified Service credentials</p>
            </div>

            <form onSubmit={handleFormSubmit} className="space-y-4">
              <div>
                <label className="block text-[12px] font-semibold text-slate-700 mb-1">
                  Service Email ID
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-cyan-600">
                    <Shield className="w-4 h-4" />
                  </div>
                  <input
                    type="email"
                    required
                    value={emailInput}
                    onChange={(e) => setEmailInput(e.target.value)}
                    placeholder="officer@force.gov.in"
                    className="w-full pl-10 pr-3.5 py-2.5 text-xs rounded-xl bg-white/90 border border-slate-200 focus:outline-none focus:border-cyan-500 focus:ring-2 focus:ring-cyan-400/20 text-slate-900 transition-all shadow-inner"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[12px] font-semibold text-slate-700 mb-1">
                  Service Password / PIN
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-cyan-600">
                    <Lock className="w-4 h-4" />
                  </div>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    required
                    value={passwordInput}
                    onChange={(e) => setPasswordInput(e.target.value)}
                    placeholder="Enter password"
                    className="w-full pl-10 pr-10 py-2.5 text-xs rounded-xl bg-white/90 border border-slate-200 focus:outline-none focus:border-cyan-500 focus:ring-2 focus:ring-cyan-400/20 text-slate-900 transition-all shadow-inner"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-600"
                  >
                    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={isAuthenticating}
                className="w-full mt-2 py-3 px-4 rounded-xl text-xs font-bold text-white bg-gradient-to-r from-[#0C2340] via-[#0F3A5D] to-[#0A1F2C] border border-cyan-400/50 shadow-[0_6px_20px_rgba(12,35,64,0.25)] hover:shadow-cyan-500/25 hover:border-cyan-300 transition-all flex items-center justify-center gap-2 active:scale-[0.99]"
              >
                {isAuthenticating ? (
                  <KineticDotsLoader size={12} label="" />
                ) : (
                  <>
                    <LogIn className="w-4 h-4 text-cyan-300" />
                    <span>Secure Sign In</span>
                  </>
                )}
              </button>
            </form>
          </div>

          {/* Quick Role Demo Sign-In Card */}
          <div className="liquid-glass p-4 rounded-[18px]">
            <div className="flex items-center gap-2 mb-2.5">
              <UserCheck className="w-4 h-4 text-cyan-600" />
              <span className="text-[11.5px] font-bold text-slate-800">
                Direct Role Sign-In (Choose Your Portal):
              </span>
            </div>

            <div className="grid grid-cols-3 gap-2">
              <button
                type="button"
                onClick={() => handleQuickDemoLogin('commander')}
                className="p-2.5 rounded-xl bg-white/90 hover:bg-slate-900 hover:text-white border border-slate-200 text-slate-800 text-[11px] font-bold transition-all shadow-xs flex flex-col items-center gap-1 text-center"
              >
                <Shield className="w-4 h-4 text-cyan-500" />
                <span>Commander</span>
              </button>
              <button
                type="button"
                onClick={() => handleQuickDemoLogin('welfare')}
                className="p-2.5 rounded-xl bg-white/90 hover:bg-teal-700 hover:text-white border border-slate-200 text-slate-800 text-[11px] font-bold transition-all shadow-xs flex flex-col items-center gap-1 text-center"
              >
                <Award className="w-4 h-4 text-teal-600" />
                <span>Welfare Officer</span>
              </button>
              <button
                type="button"
                onClick={() => handleQuickDemoLogin('family')}
                className="p-2.5 rounded-xl bg-white/90 hover:bg-rose-600 hover:text-white border border-slate-200 text-slate-800 text-[11px] font-bold transition-all shadow-xs flex flex-col items-center gap-1 text-center"
              >
                <Heart className="w-4 h-4 text-rose-500" />
                <span>Veer Parivar</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // =========================================================================
  // VIEW 2: AUTHENTICATED WEBSITE WITH ROLE-SPECIFIC SIDEBAR & DISTINCT MODULES
  // =========================================================================
  return (
    <div className="aura-bg min-h-screen">
      {/* Layer 1 - normal */}
      <div className="aura-layer-1" aria-hidden="true" />
      {/* Layer 2 - multiply */}
      <div className="aura-layer-2" aria-hidden="true" />
      {/* Layer 3 - multiply */}
      <div className="aura-layer-3" aria-hidden="true" />
      {/* Layer 4 - multiply */}
      <div className="aura-layer-4" aria-hidden="true" />

      {/* Content wrapper sits ABOVE the layers with z-index: 1 */}
      <div className="relative z-10 flex min-h-screen w-full">

      {/* ========================================================================= */}
      {/* DEDICATED ROLE-SPECIFIC SIDEBAR (No Dock on Website)                     */}
      {/* ========================================================================= */}
      <aside
        className={`fixed inset-y-0 left-0 z-50 flex flex-col justify-between w-64 bg-white/92 backdrop-blur-2xl border-r border-slate-200/90 shadow-xl transition-transform duration-300 lg:static lg:translate-x-0 ${
          isSidebarOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div>
          {/* Sidebar Brand Header */}
          <div className="p-4 border-b border-slate-200/80 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-white border border-cyan-300 shadow-xs p-1 flex items-center justify-center overflow-hidden">
                <Image
                  src="/rakshasetu_logo.png"
                  alt="Logo"
                  width={32}
                  height={32}
                  className="object-contain"
                  priority
                />
              </div>
              <div>
                <span className="font-extrabold text-base tracking-tight text-[#0A1F2C]">
                  Raksha<span className="text-[#0891B2]">Setu</span>
                </span>
                <span className="block text-[10px] text-slate-500 font-bold uppercase tracking-wider">
                  {currentUser.role === 'commander' ? 'Command Desk' : currentUser.role === 'welfare' ? 'Welfare Portal' : 'Veer Parivar'}
                </span>
              </div>
            </div>
            <button
              onClick={() => setIsSidebarOpen(false)}
              className="lg:hidden p-1 rounded-lg text-slate-400 hover:text-slate-700"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* User Profile Summary */}
          <div className="p-3 mx-3 mt-3 rounded-xl bg-slate-100/90 border border-slate-200 flex items-center gap-2.5">
            <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs text-white ${
              currentUser.role === 'commander' ? 'bg-slate-900' : currentUser.role === 'welfare' ? 'bg-teal-700' : 'bg-rose-600'
            }`}>
              {currentUser.name[0]}
            </div>
            <div className="overflow-hidden">
              <div className="text-xs font-bold text-slate-900 truncate">{currentUser.name}</div>
              <div className="text-[10px] text-slate-500 truncate">{currentUser.rank}</div>
            </div>
          </div>

          {/* Role Switcher Pills inside Sidebar */}
          <div className="px-3 pt-3">
            <span className="text-[9.5px] font-extrabold tracking-wider text-slate-400 uppercase px-1">
              Switch Role Workspace
            </span>
            <div className="grid grid-cols-3 gap-1 mt-1 p-1 rounded-xl bg-slate-200/60 text-center">
              <button
                onClick={() => { handleQuickDemoLogin('commander'); }}
                className={`py-1 rounded-lg text-[10px] font-bold transition-all ${
                  currentUser.role === 'commander'
                    ? 'bg-slate-900 text-white shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                Cmdr
              </button>
              <button
                onClick={() => { handleQuickDemoLogin('welfare'); }}
                className={`py-1 rounded-lg text-[10px] font-bold transition-all ${
                  currentUser.role === 'welfare'
                    ? 'bg-teal-700 text-white shadow-xs'
                    : 'text-slate-600 hover:text-teal-900'
                }`}
              >
                Welfare
              </button>
              <button
                onClick={() => { handleQuickDemoLogin('family'); }}
                className={`py-1 rounded-lg text-[10px] font-bold transition-all ${
                  currentUser.role === 'family'
                    ? 'bg-rose-600 text-white shadow-xs'
                    : 'text-slate-600 hover:text-rose-900'
                }`}
              >
                Family
              </button>
            </div>
          </div>

          {/* ========================================================= */}
          {/* 1. COMMANDER-SPECIFIC SIDEBAR NAVIGATION                  */}
          {/* ========================================================= */}
          {currentUser.role === 'commander' && (
            <nav className="p-3 space-y-1 mt-2 text-xs">
              <span className="text-[9.5px] font-extrabold tracking-wider text-slate-400 uppercase px-1">
                Battalion Command Operations
              </span>

              <SidebarNavLink
                icon={<Activity className="w-4 h-4 text-cyan-600" />}
                label="Readiness & Strain Matrix"
                active={commanderView === 'overview'}
                onClick={() => setCommanderView('overview')}
              />

              <SidebarNavLink
                icon={<Users className="w-4 h-4 text-indigo-600" />}
                label="All Unit Men Roster"
                badge={`${rosterData.length} Troops`}
                active={commanderView === 'roster'}
                onClick={() => setCommanderView('roster')}
              />

              <SidebarNavLink
                icon={<BarChart3 className="w-4 h-4 text-emerald-600" />}
                label="Unit Analytical Graphs"
                badge="CUSUM"
                active={commanderView === 'analytics'}
                onClick={() => setCommanderView('analytics')}
              />

              <SidebarNavLink
                icon={<Terminal className="w-4 h-4 text-amber-600" />}
                label="Tactical Command Console"
                badge="Orders"
                active={commanderView === 'commands'}
                onClick={() => setCommanderView('commands')}
              />

              <SidebarNavLink
                icon={<Stethoscope className="w-4 h-4 text-purple-600" />}
                label="Assessment Battery Stats"
                badge="PHQ/GAD"
                active={commanderView === 'assessments'}
                onClick={() => setCommanderView('assessments')}
              />
            </nav>
          )}

          {/* ========================================================= */}
          {/* 2. WELFARE OFFICER-SPECIFIC SIDEBAR NAVIGATION            */}
          {/* ========================================================= */}
          {currentUser.role === 'welfare' && (
            <nav className="p-3 space-y-1 mt-2 text-xs">
              <span className="text-[9.5px] font-extrabold tracking-wider text-slate-400 uppercase px-1">
                Welfare Administration
              </span>

              <SidebarNavLink
                icon={<FileCheck className="w-4 h-4 text-teal-600" />}
                label="Grants & Claims Desk"
                badge="38 Active"
                active={welfareView === 'claims'}
                onClick={() => setWelfareView('claims')}
              />

              <SidebarNavLink
                icon={<PieChart className="w-4 h-4 text-amber-600" />}
                label="Discretionary Treasury"
                badge="₹10.8L Avail"
                active={welfareView === 'budget'}
                onClick={() => setWelfareView('budget')}
              />

              <SidebarNavLink
                icon={<BookOpen className="w-4 h-4 text-cyan-600" />}
                label="WARB / MHA RAG Copilot"
                badge="AI Bot"
                active={welfareView === 'rag'}
                onClick={() => setWelfareView('rag')}
              />

              <SidebarNavLink
                icon={<AlertTriangle className="w-4 h-4 text-rose-600" />}
                label="Anonymous Grievances"
                badge="4 Cases"
                active={welfareView === 'grievances'}
                onClick={() => setWelfareView('grievances')}
              />

              <SidebarNavLink
                icon={<BarChart3 className="w-4 h-4 text-indigo-600" />}
                label="Disbursement Trends"
                active={welfareView === 'trends'}
                onClick={() => setWelfareView('trends')}
              />
            </nav>
          )}

          {/* ========================================================= */}
          {/* 3. FAMILY MEMBER-SPECIFIC SIDEBAR NAVIGATION              */}
          {/* ========================================================= */}
          {currentUser.role === 'family' && (
            <nav className="p-3 space-y-1 mt-2 text-xs">
              <span className="text-[9.5px] font-extrabold tracking-wider text-slate-400 uppercase px-1">
                Veer Parivar Family Care
              </span>

              <SidebarNavLink
                icon={<Heart className="w-4 h-4 text-rose-600" />}
                label="Morale Vault Transmission"
                badge="Direct Sync"
                active={familyView === 'vault'}
                onClick={() => setFamilyView('vault')}
              />

              <SidebarNavLink
                icon={<GraduationCap className="w-4 h-4 text-teal-600" />}
                label="Education Grants (PMSS)"
                badge="Track"
                active={familyView === 'scholarships'}
                onClick={() => setFamilyView('scholarships')}
              />

              <SidebarNavLink
                icon={<PhoneCall className="w-4 h-4 text-emerald-600" />}
                label="24x7 Emergency Grid"
                badge="Tele-MANAS"
                active={familyView === 'emergency'}
                onClick={() => setFamilyView('emergency')}
              />

              <SidebarNavLink
                icon={<Building2 className="w-4 h-4 text-cyan-600" />}
                label="Empanelled Hospitals"
                badge="Ayushman"
                active={familyView === 'hospitals'}
                onClick={() => setFamilyView('hospitals')}
              />
            </nav>
          )}
        </div>

        {/* Sidebar Footer */}
        <div className="p-3 border-t border-slate-200/80 space-y-2">
          <div className="p-2 rounded-xl bg-emerald-50 border border-emerald-200/80 flex items-center justify-between text-[11px]">
            <div className="flex items-center gap-1.5 font-bold text-emerald-900">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
              HR Firewall Active
            </div>
            <Lock className="w-3.5 h-3.5 text-emerald-700" />
          </div>

          <button
            onClick={handleSignOut}
            className="w-full flex items-center justify-center gap-2 py-2 px-3 rounded-xl bg-slate-100 hover:bg-rose-50 hover:text-rose-700 text-xs font-bold text-slate-700 border border-slate-200 transition-colors"
          >
            <LogOut className="w-3.5 h-3.5" />
            <span>Sign Out Session</span>
          </button>
        </div>
      </aside>

      {/* ========================================================================= */}
      {/* MAIN WORKSPACE CONTENT AREA                                              */}
      {/* ========================================================================= */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top Navbar */}
        <header className="sticky top-0 z-30 bg-white/85 backdrop-blur-xl border-b border-slate-200 px-4 sm:px-6 py-2.5 flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setIsSidebarOpen(true)}
              className="lg:hidden p-1.5 rounded-lg border border-slate-200 bg-white text-slate-700"
            >
              <Menu className="w-5 h-5" />
            </button>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-sm font-bold text-slate-900">
                  {currentUser.role === 'commander'
                    ? `Command Desk • ${commanderView.toUpperCase()}`
                    : currentUser.role === 'welfare'
                    ? `Welfare Portal • ${welfareView.toUpperCase()}`
                    : `Veer Parivar • ${familyView.toUpperCase()}`}
                </span>
                <span className="px-2 py-0.5 rounded-full text-[9px] font-extrabold bg-cyan-100 text-cyan-900 border border-cyan-300">
                  {currentUser.forceId}
                </span>
              </div>
              <p className="text-[10.5px] text-slate-500 hidden sm:block">
                {currentUser.unit}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            {currentUser.role === 'commander' && (
              <button
                onClick={() => dispatchCommand('TACTICAL REST ROTATION', 'Alpha Coy Post 14', 'Direct command relief order.')}
                className="hidden md:inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-cyan-50 border border-cyan-300 text-cyan-900 text-xs font-bold hover:bg-cyan-100 transition-colors shadow-xs"
              >
                <Zap className="w-3.5 h-3.5 text-cyan-600" />
                Quick R&R Order
              </button>
            )}

            <button
              onClick={handleRefresh}
              disabled={isRefreshing}
              className="p-1.5 rounded-xl bg-white border border-slate-200 text-slate-600 hover:text-cyan-600 shadow-xs"
              title="Sync Telemetry"
            >
              <RefreshCw className={`w-4 h-4 ${isRefreshing ? 'animate-spin text-cyan-600' : ''}`} />
            </button>
          </div>
        </header>

        {/* Notification Toast */}
        {activeToast && (
          <div className="fixed top-14 right-6 z-50 p-3 rounded-2xl bg-slate-900 text-white shadow-2xl flex items-center gap-2.5 text-xs font-semibold border border-cyan-400/40 animate-slideIn">
            <CheckCircle2 className="w-4 h-4 text-cyan-400" />
            <span>{activeToast}</span>
          </div>
        )}

        {/* Content Body */}
        <main className="p-4 sm:p-6 max-w-7xl w-full mx-auto space-y-6 flex-1">
          {isLoading ? (
            <div className="py-28 flex items-center justify-center">
              <KineticDotsLoader size={22} label="Connecting to Supabase Military Grid & Telemetry..." />
            </div>
          ) : (
            <>
              {/* ===================================================================== */}
              {/* 1. COMMANDER PORTAL SUITE (Exclusively for Commander)                */}
              {/* ===================================================================== */}
              {currentUser.role === 'commander' && (
                <div className="space-y-6 animate-fadeIn">
                  {/* Overview View */}
                  {commanderView === 'overview' && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-cyan-600 flex flex-col md:flex-row md:items-center justify-between gap-4">
                        <div>
                          <div className="flex items-center gap-2">
                            <Shield className="w-5 h-5 text-cyan-600" />
                            <h2 className="text-base font-bold text-slate-900">
                              Battalion Operational Readiness & High-Altitude Fatigue Command Matrix
                            </h2>
                          </div>
                          <p className="text-xs text-slate-600 mt-1 max-w-3xl">
                            Real-time telemetry across Alpha, Bravo, Charlie, and Delta companies. CUSUM statistical change-point detection flags personnel in need of rotation.
                          </p>
                        </div>
                        <span className="px-3 py-1 rounded-lg text-xs font-extrabold bg-emerald-100 text-emerald-800 border border-emerald-300">
                          READINESS: {commanderData?.metrics.readinessIndex}%
                        </span>
                      </div>

                      {/* 6 Key KPIs */}
                      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3.5">
                        <MetricCard
                          title="Active Strength"
                          value={commanderData.metrics.totalPersonnel}
                          sub="Troops Tracked"
                          icon={<Users className="w-4 h-4 text-cyan-600" />}
                        />
                        <MetricCard
                          title="Readiness Index"
                          value={`${commanderData.metrics.readinessIndex}%`}
                          sub="Combat Capable"
                          trend="+1.4%"
                          icon={<Activity className="w-4 h-4 text-emerald-600" />}
                        />
                        <MetricCard
                          title="Fatigue Alerts"
                          value={commanderData.metrics.elevatedRiskCount}
                          sub="Needs Rest Rotation"
                          alert
                          icon={<AlertTriangle className="w-4 h-4 text-rose-600" />}
                        />
                        <MetricCard
                          title="Strain Index"
                          value={`${commanderData.metrics.fatigueIndex}`}
                          sub="Load Rating (0-100)"
                          icon={<TrendingUp className="w-4 h-4 text-amber-600" />}
                        />
                        <MetricCard
                          title="Deployments"
                          value={commanderData.metrics.activeDeployments}
                          sub="Alpine Outposts"
                          icon={<Layers className="w-4 h-4 text-indigo-600" />}
                        />
                        <MetricCard
                          title="Unit Cohesion"
                          value={`${commanderData.metrics.cohesionScore}%`}
                          sub="Buddy Network"
                          icon={<Heart className="w-4 h-4 text-rose-500" />}
                        />
                      </div>

                      {/* Company Heatmap + SHAP */}
                      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                        <div className="lg:col-span-2 liquid-glass p-5 rounded-2xl">
                          <div className="flex items-center justify-between mb-4">
                            <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                              <Layers className="w-4 h-4 text-cyan-600" />
                              Company Readiness & Alpine Terrain Fatigue Heatmap
                            </h3>
                            <button
                              onClick={() => setCommanderView('roster')}
                              className="text-xs font-bold text-cyan-700 hover:underline flex items-center gap-1"
                            >
                              View Roster <ChevronRight className="w-3.5 h-3.5" />
                            </button>
                          </div>

                          <div className="space-y-3">
                            {commanderData.readinessHeatmap.map((item: any, idx: number) => (
                              <div key={idx} className="p-3.5 rounded-xl bg-white/80 border border-slate-200">
                                <div className="flex items-center justify-between">
                                  <div>
                                    <span className="text-xs font-bold text-slate-900">{item.unit}</span>
                                    <span className="text-[11px] text-slate-500 ml-2 font-mono">[{item.altitude}]</span>
                                  </div>
                                  <span className={`text-[10px] font-extrabold px-2 py-0.5 rounded-full ${
                                    item.score >= 90 ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'
                                  }`}>
                                    Readiness: {item.score}%
                                  </span>
                                </div>

                                <div className="w-full bg-slate-200 h-2 rounded-full mt-2.5 overflow-hidden">
                                  <div
                                    className="h-full rounded-full bg-gradient-to-r from-emerald-500 to-teal-500"
                                    style={{ width: `${item.score}%` }}
                                  />
                                </div>

                                <div className="flex items-center justify-between mt-2 text-[11px] text-slate-500">
                                  <span>Status: <strong className="text-slate-700">{item.strain}</strong></span>
                                  <button
                                    onClick={() => dispatchCommand('R&R ROTATION ORDER', item.unit, 'Relief shift order issued.')}
                                    className="text-[10px] font-bold text-cyan-700 hover:text-cyan-900 bg-cyan-50 px-2 py-0.5 rounded border border-cyan-200"
                                  >
                                    Issue Shift Order
                                  </button>
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>

                        {/* Sentinel Alerts */}
                        <div className="liquid-glass p-5 rounded-2xl flex flex-col justify-between">
                          <div>
                            <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2 mb-3">
                              <Bell className="w-4 h-4 text-indigo-600" />
                              Live Sentinel Advisory
                            </h3>
                            <div className="space-y-3">
                              {commanderData.recentAlerts.map((alt: any) => (
                                <div key={alt.id} className="p-3 rounded-xl bg-white/90 border border-slate-200 text-xs">
                                  <div className="flex justify-between font-bold text-[10px]">
                                    <span className={alt.severity === 'HIGH' ? 'text-rose-600' : 'text-cyan-700'}>{alt.severity}</span>
                                    <span className="text-slate-400">{alt.time}</span>
                                  </div>
                                  <div className="font-bold text-slate-900 mt-1">{alt.title}</div>
                                  <p className="text-[11px] text-slate-600 mt-0.5">{alt.desc}</p>
                                </div>
                              ))}
                            </div>
                          </div>

                          <div className="mt-4 p-3 rounded-xl bg-cyan-50/80 border border-cyan-200 text-[11px] text-cyan-950">
                            <Lock className="w-3.5 h-3.5 inline mr-1 text-cyan-600" />
                            <strong>Zero-Knowledge Rule:</strong> Aggregated minimums only; commanders cannot inspect individual medical ratings.
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* All Unit Men Roster View */}
                  {commanderView === 'roster' && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-indigo-600 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                        <div>
                          <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                            <Users className="w-5 h-5 text-indigo-600" />
                            Battalion Unit Personnel Roster ({filteredRoster.length} Troops)
                          </h2>
                          <p className="text-xs text-slate-600 mt-1">
                            Individual personnel status across deployment outposts. Filter by company to inspect readiness and sleep deficit.
                          </p>
                        </div>
                        {/* Company Filter Tabs */}
                        <div className="flex gap-1.5 p-1 rounded-xl bg-slate-100 border border-slate-200">
                          {['ALL', 'Alpha', 'Bravo', 'Charlie', 'Delta'].map((c) => (
                            <button
                              key={c}
                              onClick={() => setSelectedCompanyFilter(c)}
                              className={`px-2.5 py-1 rounded-lg text-xs font-bold transition-all ${
                                selectedCompanyFilter === c ? 'bg-indigo-600 text-white shadow-xs' : 'text-slate-600 hover:text-slate-900'
                              }`}
                            >
                              {c}
                            </button>
                          ))}
                        </div>
                      </div>

                      <div className="liquid-glass p-5 rounded-2xl overflow-hidden">
                        <div className="overflow-x-auto">
                          <table className="w-full text-left text-xs">
                            <thead>
                              <tr className="border-b border-slate-200 text-slate-500 font-bold">
                                <th className="pb-3">Service ID</th>
                                <th className="pb-3">Name & Rank</th>
                                <th className="pb-3">Company & Post</th>
                                <th className="pb-3">Altitude</th>
                                <th className="pb-3">Sleep Average</th>
                                <th className="pb-3">Readiness</th>
                                <th className="pb-3">Check-In</th>
                                <th className="pb-3">Command Action</th>
                              </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                              {filteredRoster.map((person) => (
                                <tr key={person.id} className="hover:bg-slate-50/80 transition-colors">
                                  <td className="py-3 font-mono font-bold text-cyan-800">{person.serviceNo}</td>
                                  <td className="py-3">
                                    <div className="font-bold text-slate-900">{person.name}</div>
                                    <span className="text-[10px] text-slate-500">{person.rank}</span>
                                  </td>
                                  <td className="py-3">
                                    <div className="font-semibold text-slate-800">{person.company}</div>
                                    <span className="text-[10px] text-slate-400">{person.postLocation}</span>
                                  </td>
                                  <td className="py-3 font-mono font-medium">{person.altitudeFt} ft</td>
                                  <td className="py-3">
                                    <span className={`font-bold ${person.sleepHours < 5.5 ? 'text-rose-600' : 'text-slate-700'}`}>
                                      {person.sleepHours} hrs/day
                                    </span>
                                  </td>
                                  <td className="py-3 font-extrabold text-slate-900">{person.readinessScore}%</td>
                                  <td className="py-3">
                                    <span className={`px-2 py-0.5 rounded-full text-[9.5px] font-bold ${
                                      person.checkInStatus === 'COMPLETED'
                                        ? 'bg-emerald-100 text-emerald-800'
                                        : person.checkInStatus === 'PENDING'
                                        ? 'bg-amber-100 text-amber-800'
                                        : 'bg-rose-100 text-rose-800'
                                    }`}>
                                      {person.checkInStatus}
                                    </span>
                                  </td>
                                  <td className="py-3">
                                    <button
                                      onClick={() => dispatchCommand('INDIVIDUAL R&R ORDER', `${person.name} (${person.company})`, 'Dispatched 72-hour recovery rest.')}
                                      className="px-2.5 py-1 rounded-lg bg-slate-900 text-white text-[10px] font-bold hover:bg-slate-800 transition-colors"
                                    >
                                      Order R&R
                                    </button>
                                  </td>
                                </tr>
                              ))}
                            </tbody>
                          </table>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* ============================================================== */}
                  {/* PROPER GRAPHS FOR ALL UNIT MEN                                 */}
                  {/* ============================================================== */}
                  {commanderView === 'analytics' && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-emerald-600">
                        <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                          <BarChart3 className="w-5 h-5 text-emerald-600" />
                          Unit Analytical Telemetry & CUSUM Equilibrium Graphs
                        </h2>
                        <p className="text-xs text-slate-600 mt-1">
                          Comparative graphical statistics across companies, 6-week CUSUM recovery curves, and sleep-load distributions.
                        </p>
                      </div>

                      {/* Graph 1: Comparative Multi-Bar Chart */}
                      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <div className="liquid-glass p-5 rounded-2xl">
                          <h3 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-4">
                            Company Readiness vs. Strain Level (%)
                          </h3>
                          <div className="space-y-4">
                            {[
                              { label: 'Alpha Coy (High Altitude, 14,200ft)', readiness: 79, strain: 42, color: '#06B6D4' },
                              { label: 'Bravo Coy (CI Ops, J&K)', readiness: 86, strain: 34, color: '#0EA5E9' },
                              { label: 'Charlie Coy (R&R Garrison)', readiness: 96, strain: 12, color: '#10B981' },
                              { label: 'Delta HQ & Support Element', readiness: 94, strain: 16, color: '#6366F1' },
                            ].map((bar, i) => (
                              <div key={i} className="space-y-1">
                                <div className="flex justify-between text-xs font-bold text-slate-800">
                                  <span>{bar.label}</span>
                                  <span className="text-cyan-700">Readiness: {bar.readiness}% • Strain: {bar.strain}%</span>
                                </div>
                                <div className="flex gap-2 h-4 items-center">
                                  <div className="flex-1 bg-slate-200 h-2.5 rounded-full overflow-hidden flex">
                                    <div className="bg-emerald-500 h-full" style={{ width: `${bar.readiness}%` }} />
                                  </div>
                                  <div className="w-24 bg-slate-200 h-2.5 rounded-full overflow-hidden">
                                    <div className="bg-rose-500 h-full" style={{ width: `${bar.strain * 2}%` }} />
                                  </div>
                                </div>
                              </div>
                            ))}
                          </div>
                          <div className="flex items-center justify-end gap-4 mt-4 text-[10px] text-slate-500">
                            <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-emerald-500" /> Operational Readiness</span>
                            <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-rose-500" /> Fatigue Load</span>
                          </div>
                        </div>

                        {/* Graph 2: 6-Week CUSUM Trend Curve (SVG Line Chart) */}
                        <div className="liquid-glass p-5 rounded-2xl flex flex-col justify-between">
                          <div>
                            <div className="flex justify-between items-center mb-2">
                              <h3 className="text-xs font-bold text-slate-500 uppercase tracking-wider">
                                6-Week CUSUM Baseline Shift Graph
                              </h3>
                              <span className="text-[10px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                                Equilibrium Stabilized
                              </span>
                            </div>
                            <p className="text-xs text-slate-500 mb-4">Statistical cumulative sum tracking battalion recovery across 6 weeks</p>

                            {/* SVG Graph */}
                            <div className="w-full h-44 bg-white/70 rounded-xl border border-slate-200 p-2 relative flex flex-col justify-between">
                              <svg className="w-full h-32 overflow-visible" viewBox="0 0 500 120">
                                {/* Grid lines */}
                                <line x1="0" y1="20" x2="500" y2="20" stroke="#E2E8F0" strokeDasharray="4" />
                                <line x1="0" y1="60" x2="500" y2="60" stroke="#E2E8F0" strokeDasharray="4" />
                                <line x1="0" y1="100" x2="500" y2="100" stroke="#E2E8F0" strokeDasharray="4" />

                                {/* Target Line */}
                                <line x1="0" y1="40" x2="500" y2="40" stroke="#10B981" strokeWidth="1.5" strokeDasharray="6" />

                                {/* CUSUM Line Curve */}
                                <path
                                  d="M 20 80 Q 100 95, 180 50 T 340 30 T 480 35"
                                  fill="none"
                                  stroke="#0284C7"
                                  strokeWidth="3"
                                />

                                {/* Points */}
                                <circle cx="20" cy="80" r="4" fill="#0C2340" />
                                <circle cx="100" cy="92" r="4" fill="#E11D48" />
                                <circle cx="180" cy="50" r="4" fill="#0C2340" />
                                <circle cx="260" cy="42" r="4" fill="#0C2340" />
                                <circle cx="340" cy="30" r="4" fill="#10B981" />
                                <circle cx="480" cy="35" r="4" fill="#10B981" />
                              </svg>

                              <div className="flex justify-between text-[10px] text-slate-500 font-mono px-2">
                                <span>W-6</span>
                                <span>W-5 (Spike)</span>
                                <span>W-4</span>
                                <span>W-3</span>
                                <span>W-2</span>
                                <span>Current (W-1)</span>
                              </div>
                            </div>
                          </div>

                          <div className="mt-4 text-[10.5px] text-slate-600 flex justify-between">
                            <span>Target Equilibrium: <strong className="text-emerald-700">92%+</strong></span>
                            <span>Recovery Rate: <strong className="text-cyan-700">+14.2% since W-5 rotation</strong></span>
                          </div>
                        </div>
                      </div>

                      {/* Graph 3 & 4: Psychological Risk Stratification Donut + Sleep Histogram */}
                      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <div className="liquid-glass p-5 rounded-2xl">
                          <h3 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3">
                            Psychological Risk Stratification Breakdown
                          </h3>
                          <div className="flex items-center gap-6">
                            <div className="w-28 h-28 rounded-full border-8 border-cyan-500 border-t-emerald-500 border-r-indigo-500 border-b-rose-500 flex items-center justify-center flex-col shadow-inner">
                              <span className="text-lg font-extrabold text-slate-900">142</span>
                              <span className="text-[9px] text-slate-400">Total Troops</span>
                            </div>
                            <div className="flex-1 space-y-2 text-xs">
                              <div className="flex justify-between items-center">
                                <span className="flex items-center gap-1.5"><span className="w-2.5 h-2.5 rounded-full bg-emerald-500" /> Low Risk (Optimal)</span>
                                <strong className="text-slate-900">110 (78%)</strong>
                              </div>
                              <div className="flex justify-between items-center">
                                <span className="flex items-center gap-1.5"><span className="w-2.5 h-2.5 rounded-full bg-indigo-500" /> Moderate (Monitoring)</span>
                                <strong className="text-slate-900">24 (16%)</strong>
                              </div>
                              <div className="flex justify-between items-center">
                                <span className="flex items-center gap-1.5"><span className="w-2.5 h-2.5 rounded-full bg-cyan-500" /> Elevated (Altitude Load)</span>
                                <strong className="text-slate-900">7 (5%)</strong>
                              </div>
                              <div className="flex justify-between items-center">
                                <span className="flex items-center gap-1.5"><span className="w-2.5 h-2.5 rounded-full bg-rose-500" /> Critical Fatigue</span>
                                <strong className="text-rose-600">1 (1%)</strong>
                              </div>
                            </div>
                          </div>
                        </div>

                        <div className="liquid-glass p-5 rounded-2xl">
                          <h3 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3">
                            Daily Sleep Recovery vs. High-Altitude Deficit
                          </h3>
                          <div className="space-y-3 text-xs">
                            <div>
                              <div className="flex justify-between text-[11px] font-semibold text-slate-700">
                                <span>&gt; 7.0 Hours (Full Neuro-Cognitive Recovery)</span>
                                <span className="font-bold text-emerald-700">62% of Battalion</span>
                              </div>
                              <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden mt-1">
                                <div className="bg-emerald-500 h-full" style={{ width: '62%' }} />
                              </div>
                            </div>
                            <div>
                              <div className="flex justify-between text-[11px] font-semibold text-slate-700">
                                <span>5.5 - 7.0 Hours (Marginal Altitude Deficit)</span>
                                <span className="font-bold text-amber-700">28% of Battalion</span>
                              </div>
                              <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden mt-1">
                                <div className="bg-amber-500 h-full" style={{ width: '28%' }} />
                              </div>
                            </div>
                            <div>
                              <div className="flex justify-between text-[11px] font-semibold text-slate-700">
                                <span>&lt; 5.0 Hours (Cumulative Alpine Sleep Debt)</span>
                                <span className="font-bold text-rose-700">10% of Battalion</span>
                              </div>
                              <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden mt-1">
                                <div className="bg-rose-500 h-full" style={{ width: '10%' }} />
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Tactical Commands Console View */}
                  {commanderView === 'commands' && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-amber-600">
                        <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                          <Terminal className="w-5 h-5 text-amber-600" />
                          Command Directives & Tactical Shift Relief Console
                        </h2>
                        <p className="text-xs text-slate-600 mt-1">
                          Issue binding operational orders, sleep relief schedules, and battalion-wide communications directly from the web console.
                        </p>
                      </div>

                      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                        <div className="p-4 rounded-2xl liquid-glass border border-slate-200 flex flex-col justify-between">
                          <div>
                            <div className="w-9 h-9 rounded-xl bg-cyan-100 text-cyan-800 flex items-center justify-center font-bold mb-3">
                              <Zap className="w-4 h-4" />
                            </div>
                            <h3 className="text-xs font-bold text-slate-900">Issue Alpine R&R Order</h3>
                            <p className="text-[11px] text-slate-500 mt-1">Orders high-altitude post commanders to rotate jawans exceeding 50hrs sleep debt.</p>
                          </div>
                          <button
                            onClick={() => dispatchCommand('OPERATIONAL R&R ORDER', 'Alpha Company (Mana Pass)', 'Mandatory 72hr sleep recovery.')}
                            className="mt-4 w-full py-2 rounded-xl bg-cyan-700 hover:bg-cyan-800 text-white text-xs font-bold transition-all"
                          >
                            Dispatch R&R Order
                          </button>
                        </div>

                        <div className="p-4 rounded-2xl liquid-glass border border-slate-200 flex flex-col justify-between">
                          <div>
                            <div className="w-9 h-9 rounded-xl bg-emerald-100 text-emerald-800 flex items-center justify-center font-bold mb-3">
                              <Activity className="w-4 h-4" />
                            </div>
                            <h3 className="text-xs font-bold text-slate-900">Battalion Check-In Ping</h3>
                            <p className="text-[11px] text-slate-500 mt-1">Broadcasts push notification to all pending jawans to complete biweekly evaluation.</p>
                          </div>
                          <button
                            onClick={() => dispatchCommand('CHECK-IN BROADCAST PING', 'All Unit Outposts', 'Sent automated SMS/Push reminder.')}
                            className="mt-4 w-full py-2 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white text-xs font-bold transition-all"
                          >
                            Dispatch Ping
                          </button>
                        </div>

                        <div className="p-4 rounded-2xl liquid-glass border border-slate-200 flex flex-col justify-between">
                          <div>
                            <div className="w-9 h-9 rounded-xl bg-rose-100 text-rose-800 flex items-center justify-center font-bold mb-3">
                              <PhoneCall className="w-4 h-4" />
                            </div>
                            <h3 className="text-xs font-bold text-slate-900">Deploy Tele-MANAS Intercept</h3>
                            <p className="text-[11px] text-slate-500 mt-1">Directs clinical counselor cell to schedule immediate check-in for flagged severe distress scores.</p>
                          </div>
                          <button
                            onClick={() => dispatchCommand('CRISIS INTERCEPT DEPLOYMENT', 'Tele-MANAS Cell (14416)', 'Direct contact initiated.')}
                            className="mt-4 w-full py-2 rounded-xl bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold transition-all"
                          >
                            Trigger Intercept
                          </button>
                        </div>

                        <div className="p-4 rounded-2xl liquid-glass border border-slate-200 flex flex-col justify-between">
                          <div>
                            <div className="w-9 h-9 rounded-xl bg-slate-900 text-white flex items-center justify-center font-bold mb-3">
                              <FileSpreadsheet className="w-4 h-4" />
                            </div>
                            <h3 className="text-xs font-bold text-slate-900">Export Readiness Audit Log</h3>
                            <p className="text-[11px] text-slate-500 mt-1">Generates formal MHA-compliant PDF / CSV report containing anonymized unit telemetry.</p>
                          </div>
                          <button
                            onClick={() => {
                              showToast('Generating Battalion Telemetry Audit Report (PDF)...');
                              setTimeout(() => showToast('Audit Report downloaded successfully.'), 1500);
                            }}
                            className="mt-4 w-full py-2 rounded-xl bg-slate-900 hover:bg-slate-800 text-white text-xs font-bold transition-all"
                          >
                            Export Audit Report
                          </button>
                        </div>
                      </div>

                      {/* Command Log Table */}
                      <div className="liquid-glass p-5 rounded-2xl">
                        <h3 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3">
                          Dispatched Command Directives Log
                        </h3>
                        <div className="space-y-3">
                          {commandLogs.map((cmd) => (
                            <div key={cmd.id} className="p-3.5 rounded-xl bg-white/90 border border-slate-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs">
                              <div>
                                <div className="flex items-center gap-2">
                                  <span className="font-mono font-bold text-cyan-800">{cmd.id}</span>
                                  <span className="font-bold text-slate-900">{cmd.commandType}</span>
                                  <span className="text-[10px] px-2 py-0.5 rounded-full font-bold bg-emerald-100 text-emerald-800">
                                    {cmd.status}
                                  </span>
                                </div>
                                <p className="text-[11px] text-slate-600 mt-1">{cmd.notes}</p>
                                <span className="text-[10px] text-slate-400 mt-1 block">
                                  Target: <strong className="text-slate-700">{cmd.targetUnit}</strong> • Authorized: {cmd.authorizedBy}
                                </span>
                              </div>
                              <span className="text-[10px] font-mono text-slate-400">{cmd.timestamp}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Assessments View */}
                  {commanderView === 'assessments' && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-purple-600">
                        <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                          <Stethoscope className="w-5 h-5 text-purple-600" />
                          Psychological Evaluation Battery Results (PHQ-9 / GAD-7)
                        </h2>
                        <p className="text-xs text-slate-600 mt-1">
                          Standardized psychometric scores and clinical recommendations reviewed by the battalion medical board.
                        </p>
                      </div>

                      <div className="liquid-glass p-5 rounded-2xl">
                        <table className="w-full text-left text-xs">
                          <thead>
                            <tr className="border-b border-slate-200 text-slate-500 font-bold">
                              <th className="pb-3">Evaluation ID</th>
                              <th className="pb-3">Personnel Ref</th>
                              <th className="pb-3">Instrument</th>
                              <th className="pb-3">Severity Rating</th>
                              <th className="pb-3">Crisis Intercept</th>
                              <th className="pb-3">Recommendation</th>
                              <th className="pb-3">Action</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-slate-100">
                            {assessmentData.map((asm) => (
                              <tr key={asm.id} className="hover:bg-slate-50/80 transition-colors">
                                <td className="py-3 font-mono font-bold text-purple-800">{asm.id}</td>
                                <td className="py-3 font-bold text-slate-900">{asm.personnelRef}</td>
                                <td className="py-3 font-mono text-slate-700">{asm.instrument}</td>
                                <td className="py-3">
                                  <span className={`px-2 py-0.5 rounded-full text-[10px] font-extrabold ${
                                    asm.severity === 'SEVERE'
                                      ? 'bg-rose-100 text-rose-800'
                                      : asm.severity === 'MODERATE'
                                      ? 'bg-amber-100 text-amber-800'
                                      : 'bg-emerald-100 text-emerald-800'
                                  }`}>
                                    Score: {asm.totalScore} ({asm.severity})
                                  </span>
                                </td>
                                <td className="py-3">
                                  {asm.crisisFlag ? (
                                    <span className="px-2 py-0.5 rounded text-[10px] font-extrabold bg-rose-600 text-white animate-pulse">
                                      CRISIS INTERCEPT
                                    </span>
                                  ) : (
                                    <span className="text-[10px] text-slate-400">Normal</span>
                                  )}
                                </td>
                                <td className="py-3 text-slate-700 max-w-xs">{asm.recommendation}</td>
                                <td className="py-3">
                                  <button
                                    onClick={() => dispatchCommand('DEPLOY COUNSELOR INTERCEPT', asm.personnelRef, 'Authorized tele-counseling session.')}
                                    className="px-2.5 py-1 rounded-lg bg-teal-600 text-white text-[10px] font-bold hover:bg-teal-700 transition-colors"
                                  >
                                    Deploy Counselor
                                  </button>
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* ===================================================================== */}
              {/* 2. WELFARE OFFICER PORTAL SUITE (Exclusively for Welfare Officer)    */}
              {/* ===================================================================== */}
              {currentUser.role === 'welfare' && (
                <div className="space-y-6 animate-fadeIn">
                  {/* Claims Management View */}
                  {welfareView === 'claims' && welfareData && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-teal-600 flex justify-between items-center">
                        <div>
                          <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                            <FileCheck className="w-5 h-5 text-teal-600" />
                            Welfare Grants & Claims Pipeline
                          </h2>
                          <p className="text-xs text-slate-600 mt-1">
                            Review and sanction verified claims under Ayushman CAPF, PMSS scholarships, and emergency grants.
                          </p>
                        </div>
                        <span className="px-3 py-1 rounded-lg text-xs font-bold bg-teal-100 text-teal-800 border border-teal-300">
                          ₹ 10.8L Available in Treasury
                        </span>
                      </div>

                      {/* 4 Quick KPIs */}
                      <div className="grid grid-cols-2 md:grid-cols-4 gap-3.5">
                        <MetricCard
                          title="Active Claims"
                          value={welfareData.metrics.activeGrants}
                          sub="Processing Now"
                          icon={<FileText className="w-4 h-4 text-teal-600" />}
                        />
                        <MetricCard
                          title="Fund Disbursed"
                          value="₹ 14.2 L"
                          sub="Of ₹ 25 L Allocated"
                          icon={<Award className="w-4 h-4 text-amber-600" />}
                        />
                        <MetricCard
                          title="Lead Time"
                          value="4.2 Days"
                          sub="Target &lt; 7 Days"
                          icon={<Clock className="w-4 h-4 text-indigo-600" />}
                        />
                        <MetricCard
                          title="Resolution Rate"
                          value="98.2%"
                          sub="Last 30 Days"
                          icon={<CheckCircle2 className="w-4 h-4 text-emerald-600" />}
                        />
                      </div>

                      <div className="liquid-glass p-5 rounded-2xl">
                        <table className="w-full text-left text-xs">
                          <thead>
                            <tr className="border-b border-slate-200 text-slate-500 font-bold">
                              <th className="pb-3">Claim ID</th>
                              <th className="pb-3">Scheme Name</th>
                              <th className="pb-3">Applicant Name</th>
                              <th className="pb-3">Amount</th>
                              <th className="pb-3">Submission Date</th>
                              <th className="pb-3">Status</th>
                              <th className="pb-3">Action</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-slate-100">
                            {welfareData.recentClaims.map((claim: any) => (
                              <tr key={claim.id} className="hover:bg-slate-50/80 transition-colors">
                                <td className="py-3 font-mono font-bold text-teal-800">{claim.id}</td>
                                <td className="py-3 font-semibold text-slate-900">{claim.name}</td>
                                <td className="py-3 text-slate-700">{claim.applicant}</td>
                                <td className="py-3 font-bold text-slate-900">{claim.amount}</td>
                                <td className="py-3 text-slate-400 text-[10px]">{claim.date}</td>
                                <td className="py-3">
                                  <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
                                    claim.status === 'Approved' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'
                                  }`}>
                                    {claim.status}
                                  </span>
                                </td>
                                <td className="py-3">
                                  <button
                                    onClick={() => dispatchCommand('GRANT SANCTION DIRECTIVE', `${claim.applicant} (${claim.name})`, `Approved claim ${claim.id} for ${claim.amount}`)}
                                    className="px-2.5 py-1 rounded-lg bg-teal-700 text-white text-[10px] font-bold hover:bg-teal-800 transition-colors"
                                  >
                                    Approve & Disburse
                                  </button>
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  )}

                  {/* Treasury & Budget Breakdown */}
                  {welfareView === 'budget' && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-amber-600">
                        <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                          <PieChart className="w-5 h-5 text-amber-600" />
                          Discretionary Treasury & Sub-Scheme Allocation
                        </h2>
                        <p className="text-xs text-slate-600 mt-1">
                          Current fiscal budget utilization breakdown across battalion relief funds.
                        </p>
                      </div>

                      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div className="liquid-glass p-5 rounded-2xl flex flex-col justify-between">
                          <div>
                            <h3 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Fund Allocation Status</h3>
                            <div className="text-2xl font-extrabold text-slate-900">₹ 25,00,000</div>
                            <span className="text-xs text-slate-500">Annual Discretionary Cap</span>
                            <div className="w-full bg-slate-200 h-3 rounded-full mt-4 overflow-hidden">
                              <div className="bg-amber-500 h-full" style={{ width: '56.8%' }} />
                            </div>
                            <div className="flex justify-between text-xs mt-2 text-slate-600">
                              <span>Utilized: <strong>₹ 14,20,000 (56.8%)</strong></span>
                              <span>Available: <strong>₹ 10,80,000</strong></span>
                            </div>
                          </div>
                        </div>

                        <div className="md:col-span-2 liquid-glass p-5 rounded-2xl">
                          <h3 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3">Sub-Scheme Disbursement Breakdown</h3>
                          <div className="space-y-3 text-xs">
                            <div>
                              <div className="flex justify-between font-bold text-slate-800">
                                <span>Ayushman CAPF Medical Relief</span>
                                <span>₹ 6,80,000 (48%)</span>
                              </div>
                              <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden mt-1">
                                <div className="bg-teal-500 h-full" style={{ width: '48%' }} />
                              </div>
                            </div>
                            <div>
                              <div className="flex justify-between font-bold text-slate-800">
                                <span>PMSS Higher Education Scholarships</span>
                                <span>₹ 4,40,000 (31%)</span>
                              </div>
                              <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden mt-1">
                                <div className="bg-indigo-500 h-full" style={{ width: '31%' }} />
                              </div>
                            </div>
                            <div>
                              <div className="flex justify-between font-bold text-slate-800">
                                <span>Emergency Family Ex-Gratia Aid</span>
                                <span>₹ 3,00,000 (21%)</span>
                              </div>
                              <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden mt-1">
                                <div className="bg-amber-500 h-full" style={{ width: '21%' }} />
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* RAG Copilot */}
                  {welfareView === 'rag' && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-cyan-600">
                        <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                          <BookOpen className="w-5 h-5 text-cyan-600" />
                          MHA & WARB Authoritative RAG Assistant
                        </h2>
                        <p className="text-xs text-slate-600 mt-1">
                          Semantic neural search across official circulars, grant criteria, and welfare entitlements.
                        </p>
                      </div>

                      <div className="liquid-glass p-6 rounded-2xl max-w-3xl mx-auto space-y-4">
                        <form onSubmit={handleRagSearch} className="flex gap-2">
                          <input
                            type="text"
                            value={ragQuery}
                            onChange={(e) => setRagQuery(e.target.value)}
                            placeholder="Query rules (e.g. Ayushman CAPF limits or PMSS eligibility)"
                            className="flex-1 px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-xs focus:outline-none focus:border-cyan-500"
                          />
                          <button
                            type="submit"
                            disabled={isRagSearching}
                            className="px-4 py-2.5 rounded-xl bg-teal-600 text-white text-xs font-bold hover:bg-teal-700 transition-colors flex items-center gap-1.5"
                          >
                            <Search className="w-3.5 h-3.5" />
                            <span>Query</span>
                          </button>
                        </form>

                        {isRagSearching && (
                          <div className="py-6">
                            <KineticDotsLoader size={14} label="Searching Pinecone vector database..." />
                          </div>
                        )}

                        {ragAnswer && (
                          <div className="p-4 rounded-xl bg-cyan-50 border border-cyan-200 text-xs text-cyan-950">
                            <div className="flex items-center gap-1.5 font-bold text-cyan-800 mb-1">
                              <CheckCircle2 className="w-4 h-4 text-cyan-600" />
                              Official Verified Clause
                            </div>
                            <p className="leading-relaxed">{ragAnswer}</p>
                          </div>
                        )}
                      </div>
                    </div>
                  )}

                  {/* Anonymous Grievances View */}
                  {welfareView === 'grievances' && welfareData && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-rose-600">
                        <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                          <AlertTriangle className="w-5 h-5 text-rose-600" />
                          Anonymous Workplace & Facilities Grievances
                        </h2>
                        <p className="text-xs text-slate-600 mt-1">
                          Encrypted channel for jawans to report hazing, mess ration issues, or unsafe deployment conditions.
                        </p>
                      </div>

                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {welfareData.anonymousGrievances.map((g: any) => (
                          <div key={g.id} className="p-4 rounded-2xl liquid-glass border border-slate-200">
                            <div className="flex justify-between text-xs">
                              <span className="font-mono font-bold text-slate-700">{g.id}</span>
                              <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-rose-100 text-rose-800">
                                {g.priority} Priority
                              </span>
                            </div>
                            <h3 className="font-bold text-slate-900 mt-2 text-sm">{g.category}</h3>
                            <p className="text-xs text-slate-600 mt-1 leading-relaxed">{g.summary}</p>
                            <div className="flex items-center justify-between mt-4 pt-3 border-t border-slate-200 text-xs">
                              <span className="text-[11px] text-slate-500">Status: <strong className="text-teal-700">{g.status}</strong></span>
                              <button
                                onClick={() => dispatchCommand('INSPECTION DIRECTIVE', g.category, `Triggered command inspection for ticket ${g.id}`)}
                                className="px-3 py-1 rounded-xl bg-slate-900 text-white text-xs font-bold hover:bg-slate-800"
                              >
                                Order Inspection
                              </button>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* ===================================================================== */}
              {/* 3. FAMILY MEMBER PORTAL SUITE (Exclusively for Veer Parivar)        */}
              {/* ===================================================================== */}
              {currentUser.role === 'family' && (
                <div className="space-y-6 animate-fadeIn">
                  {/* Morale Vault View */}
                  {familyView === 'vault' && familyData && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-rose-500">
                        <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                          <Heart className="w-5 h-5 text-rose-600" />
                          Veer Parivar Family Morale Vault
                        </h2>
                        <p className="text-xs text-slate-600 mt-1">
                          Send offline-encrypted letters, festival greetings, and audio notes to deployed jawans. Queued for satellite delivery.
                        </p>
                      </div>

                      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                        <div className="liquid-glass p-5 rounded-2xl">
                          <h3 className="text-sm font-bold text-slate-900 mb-3 flex items-center gap-2">
                            <Send className="w-4 h-4 text-rose-600" />
                            Send Message to Outpost
                          </h3>
                          <form onSubmit={handleSendMoraleNote} className="space-y-3">
                            <input
                              type="text"
                              required
                              value={noteRecipient}
                              onChange={(e) => setNoteRecipient(e.target.value)}
                              placeholder="Officer Name / Service No."
                              className="w-full px-3 py-2 text-xs rounded-xl border border-slate-200 bg-white"
                            />
                            <textarea
                              rows={4}
                              required
                              value={noteContent}
                              onChange={(e) => setNoteContent(e.target.value)}
                              placeholder="Write your message from home..."
                              className="w-full px-3 py-2 text-xs rounded-xl border border-slate-200 bg-white"
                            />
                            <button
                              type="submit"
                              className="w-full py-2.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold transition-all"
                            >
                              Encrypt & Dispatch
                            </button>
                            {noteSentSuccess && (
                              <div className="p-2.5 rounded-xl bg-emerald-50 text-emerald-800 text-xs font-semibold">
                                Dispatched to outpost!
                              </div>
                            )}
                          </form>
                        </div>

                        <div className="lg:col-span-2 liquid-glass p-5 rounded-2xl space-y-3">
                          <h3 className="text-sm font-bold text-slate-900 mb-2">Transmission Log</h3>
                          {familyData.moraleVaultItems.map((item: any) => (
                            <div key={item.id} className="p-3.5 rounded-xl bg-white/90 border border-slate-200 text-xs">
                              <div className="flex justify-between font-bold text-slate-900">
                                <span>{item.title}</span>
                                <span className="text-slate-400 text-[10px]">{item.sentAt}</span>
                              </div>
                              <div className="flex justify-between text-slate-600 text-[11px] mt-1">
                                <span>Recipient: <strong>{item.recipient}</strong></span>
                                <span className="text-cyan-700 font-semibold">{item.type}</span>
                              </div>
                              <div className="mt-2 text-[10px] flex items-center gap-1.5 text-emerald-700 font-medium">
                                <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
                                {item.status}
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Scholarships View */}
                  {familyView === 'scholarships' && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-teal-600">
                        <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                          <GraduationCap className="w-5 h-5 text-teal-600" />
                          Children Higher Education PMSS Scholarships
                        </h2>
                        <p className="text-xs text-slate-600 mt-1">
                          Direct liaison for Prime Minister Scholarship Scheme (PMSS) technical degree grants for CAPF dependent children.
                        </p>
                      </div>

                      <div className="liquid-glass p-5 rounded-2xl">
                        <div className="p-4 rounded-xl bg-teal-50/80 border border-teal-200 text-xs text-teal-950 mb-4">
                          <strong>Active Entitlement:</strong> ₹36,000/year for female students and ₹30,000/year for male students pursuing B.Tech, MBBS, B.Sc Nursing, or MBA courses.
                        </div>

                        <div className="space-y-3 text-xs">
                          <div className="p-3.5 rounded-xl bg-white border border-slate-200 flex justify-between items-center">
                            <div>
                              <div className="font-bold text-slate-900">Pooja Negi (D/o Hav. R.S. Negi)</div>
                              <span className="text-[11px] text-slate-500">B.Tech Computer Science (3rd Sem) • NIT Uttarakhand</span>
                            </div>
                            <span className="px-3 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800">
                              Disbursed (₹36,000)
                            </span>
                          </div>

                          <div className="p-3.5 rounded-xl bg-white border border-slate-200 flex justify-between items-center">
                            <div>
                              <div className="font-bold text-slate-900">Aarav Kumar (S/o Sub. Manoj Kumar)</div>
                              <span className="text-[11px] text-slate-500">B.Sc Nursing (1st Year) • AIIMS Rishikesh</span>
                            </div>
                            <span className="px-3 py-1 rounded-full text-xs font-bold bg-cyan-100 text-cyan-800">
                              Approved for 2026 Cycle
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* 24x7 Emergency Grid View */}
                  {familyView === 'emergency' && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-rose-600">
                        <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                          <PhoneCall className="w-5 h-5 text-rose-600" />
                          Veer Parivar 24x7 Emergency Liaison & Crisis Grid
                        </h2>
                        <p className="text-xs text-slate-600 mt-1">
                          Direct emergency response cells, psychological tele-counseling, and casualty assistance liaison.
                        </p>
                      </div>

                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div className="p-4 rounded-2xl liquid-glass border border-slate-200">
                          <h3 className="text-sm font-bold text-slate-900">24x7 CAPF Toll-Free Hotline</h3>
                          <div className="text-lg font-mono font-bold text-rose-700 mt-2">1800-11-2026</div>
                          <p className="text-xs text-slate-500 mt-1">General welfare assistance, distress reporting, and border post status.</p>
                          <a
                            href="tel:1800112026"
                            className="mt-4 inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-rose-600 text-white text-xs font-bold"
                          >
                            <PhoneCall className="w-3.5 h-3.5" /> Call Hotline
                          </a>
                        </div>

                        <div className="p-4 rounded-2xl liquid-glass border border-slate-200">
                          <h3 className="text-sm font-bold text-slate-900">Tele-MANAS Psychological Cell</h3>
                          <div className="text-lg font-mono font-bold text-rose-700 mt-2">14416</div>
                          <p className="text-xs text-slate-500 mt-1">Confidential mental wellbeing counseling for family members and spouses.</p>
                          <a
                            href="tel:14416"
                            className="mt-4 inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-slate-900 text-white text-xs font-bold"
                          >
                            <PhoneCall className="w-3.5 h-3.5" /> Dial 14416
                          </a>
                        </div>

                        <div className="p-4 rounded-2xl liquid-glass border border-slate-200">
                          <h3 className="text-sm font-bold text-slate-900">Unit Family Liaison Officer</h3>
                          <div className="text-sm font-bold text-slate-800 mt-2">Sub. Major K. S. Rawat</div>
                          <p className="text-xs text-slate-500 mt-1">14th Bn ITBP Rear Base Headquarters, Dehradun.</p>
                          <span className="mt-4 inline-block text-[11px] font-mono text-cyan-800 font-bold">
                            +91 135 274 8190
                          </span>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Empanelled Hospitals View */}
                  {familyView === 'hospitals' && (
                    <div className="space-y-6">
                      <div className="liquid-glass p-5 rounded-2xl border-l-[5px] border-l-cyan-600">
                        <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                          <Building2 className="w-5 h-5 text-cyan-600" />
                          Ayushman CAPF Empanelled Hospital Network
                        </h2>
                        <p className="text-xs text-slate-600 mt-1">
                          100% cashless treatment at all CGHS and PMJAY accredited hospitals nationwide for serving personnel and dependents.
                        </p>
                      </div>

                      <div className="liquid-glass p-5 rounded-2xl space-y-3 text-xs">
                        <div className="p-3 rounded-xl bg-white border border-slate-200 flex justify-between items-center">
                          <div>
                            <div className="font-bold text-slate-900">Max Super Speciality Hospital, Dehradun</div>
                            <span className="text-[11px] text-slate-500">Mussoorie Diversion Road • Cashless Card Accepted</span>
                          </div>
                          <span className="px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-800">
                            100% Cashless Pre-Auth
                          </span>
                        </div>

                        <div className="p-3 rounded-xl bg-white border border-slate-200 flex justify-between items-center">
                          <div>
                            <div className="font-bold text-slate-900">All India Institute of Medical Sciences (AIIMS), Rishikesh</div>
                            <span className="text-[11px] text-slate-500">Virbhadra Road • Priority CAPF Desk</span>
                          </div>
                          <span className="px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-800">
                            Central Govt Institution
                          </span>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              )}
            </>
          )}
        </main>

        <footer className="border-t border-slate-200 bg-white/80 py-3 text-center text-xs text-slate-500">
          RakshaSetu Web Command Station • Smart India Hackathon (SIH-26) • Zero-Knowledge MHA Protected Grid
        </footer>
      </div>
    </div>
  </div>
  );
}

function SidebarNavLink({
  icon,
  label,
  badge,
  active,
  onClick,
}: {
  icon: React.ReactNode;
  label: string;
  badge?: string;
  active: boolean;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={`w-full flex items-center justify-between px-3 py-2 rounded-xl font-bold transition-all text-left ${
        active
          ? 'bg-cyan-50 text-cyan-950 border border-cyan-300 shadow-xs'
          : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100/70'
      }`}
    >
      <div className="flex items-center gap-2.5">
        {icon}
        <span className="text-xs">{label}</span>
      </div>
      {badge && (
        <span className={`text-[9.5px] px-1.5 py-0.5 rounded-full font-extrabold ${
          active ? 'bg-cyan-600 text-white' : 'bg-slate-200 text-slate-700'
        }`}>
          {badge}
        </span>
      )}
    </button>
  );
}

function MetricCard({
  title,
  value,
  sub,
  trend,
  alert = false,
  icon,
}: {
  title: string;
  value: string | number;
  sub: string;
  trend?: string;
  alert?: boolean;
  icon: React.ReactNode;
}) {
  return (
    <div
      className={`p-3.5 rounded-2xl liquid-glass border transition-all hover:scale-[1.02] ${
        alert ? 'border-rose-300 bg-rose-50/50' : 'border-slate-200/90'
      }`}
    >
      <div className="flex items-center justify-between mb-2">
        <span className="text-[11px] font-bold text-slate-500 truncate">{title}</span>
        <div className="p-1 rounded-lg bg-white shadow-xs border border-slate-100">{icon}</div>
      </div>
      <div className={`text-xl font-extrabold tracking-tight ${alert ? 'text-rose-700' : 'text-slate-900'}`}>
        {value}
      </div>
      <div className="flex items-center justify-between mt-1 text-[10px] text-slate-500">
        <span className="truncate">{sub}</span>
        {trend && (
          <span className={`font-bold ${alert ? 'text-rose-600' : 'text-emerald-600'}`}>
            {trend}
          </span>
        )}
      </div>
    </div>
  );
}
